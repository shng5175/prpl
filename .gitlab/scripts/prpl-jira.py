#!/usr/bin/env python3

import re
import sys
import os
import glob
import logging
import argparse

from jira import JIRA
from dataclasses import dataclass


@dataclass
class BuildLogFailure:
    path: str
    step: str
    name: str
    tail_log: list


class BuildLogAnalyzer:
    # make[3]: *** [Makefile:154: /builds/swpal_6x-uci-1.0.0.1.tar.bz2] Error 128
    RE_MAKE_ERROR = re.compile(r"make\[\d+\]: \*\*\* (.*) Error")

    # Makefile:563: recipe for target 'lldpcli' failed
    RE_MAKE_RECIPE_FAILED = re.compile(
        r"^Makefile:\d+: recipe for target '(.*)' failed"
    )

    def __init__(self, log_dir):
        self.log_dir = log_dir
        self._failures = []
        self.analyze_logs()

    def get_tail_log(self, path):
        tail_log = []
        re_matchers = [self.RE_MAKE_ERROR, self.RE_MAKE_RECIPE_FAILED]

        def add_tail_log(line):
            tail_log_goal = 4
            tail_log.append(line)
            truncate = len(tail_log) - tail_log_goal
            if truncate > 0:
                return tail_log[truncate:]
            return tail_log

        with open(path, "r") as fd:
            for line in fd:
                line = line.rstrip()
                if len(line) == 0:
                    continue

                tail_log = add_tail_log(line)

                for matcher in re_matchers:
                    if matcher.match(line):
                        return tail_log

    def process_log_file(self, path):
        path = os.path.normpath(path)
        filename = os.path.basename(path)
        dirname = os.path.dirname(path)
        package = dirname.split(os.sep)[-1]
        (step, _) = os.path.splitext(filename)

        if step == "check-compile":
            return

        tail_log = self.get_tail_log(path)
        if not tail_log:
            return

        self._failures.append(BuildLogFailure(path, step, package, tail_log))

    def analyze_logs(self):
        glob_pattern = os.path.join(self.log_dir, "**/**.txt")
        for item in glob.iglob(glob_pattern, recursive=True):
            if os.path.isfile(item):
                self.process_log_file(item)

    def failures(self):
        return self._failures

    def failures_jira_string(self):
        if not self._failures:
            return ""

        r = "\nSeems like there are build issues with following items:\n"
        for f in self._failures:
            r += f" * {f.name} ({f.step}):\n"
            for line in f.tail_log:
                r += f" ** {line}\n"
            r += "\n"

        return r


class JiraHelper:
    def __init__(self, args):
        self.args = args
        self.login()

    def login(self):
        cert_data = None
        args = self.args

        with open(args.private_key, "r") as cert_file:
            cert_data = cert_file.read()

        oauth_dict = {
            "access_token": args.access_token,
            "access_token_secret": args.access_token_secret,
            "consumer_key": args.consumer_key,
            "key_cert": cert_data,
        }

        self.jira = JIRA({"server": args.instance_url}, oauth=oauth_dict)

    def create_or_update_issue(self, failure_type, failure_details):
        args = self.args
        job = os.getenv("CI_JOB_NAME", "job")
        project = os.getenv("CI_PROJECT_NAME", "project")
        project_url = os.getenv("CI_PROJECT_URL", "https://project_url")
        branch = os.getenv("CI_COMMIT_BRANCH", "branch")
        job_url = os.getenv("CI_JOB_URL", "https://job_url")
        commit = os.getenv("CI_COMMIT_SHORT_SHA", "commit_sha")
        commit_message = os.getenv("CI_COMMIT_MESSAGE", "foor bar baz")

        summary = f"CI {failure_type} failure in {project}/{branch} during {job}"

        description = (
            f"Just noticed {failure_type} failure during execution of "
            f"[{job}|{job_url}] CI job in _{project}/{branch}_ which is now at "
            f"[{commit}|{project_url}/-/commit/{commit}] commit:"
            "{noformat}"
            f"{commit_message}"
            "{noformat}"
            f"{failure_details}"
        )

        if args.dry_run:
            logging.info(description)

        jql = f"""
            project={args.project} AND resolution = Unresolved AND summary ~ '{summary}'
        """
        existing_issue = self.jira.search_issues(jql, maxResults=1)
        if existing_issue:
            existing_issue = self.jira.issue(existing_issue[0].key)
            logging.info(
                f"Updating ({existing_issue.key}) {existing_issue.fields.summary}"
            )

            if not args.dry_run:
                self.jira.add_comment(existing_issue, description)

            return existing_issue

        if args.dry_run:
            logging.info(f"Would create new issue: '{self.args.project}/{summary}'")
            return

        new_issue = self.jira.create_issue(
            project=self.args.project,
            summary=summary,
            description=description,
            issuetype={"name": "Bug"},
            fixVersions=[{"name": "1.1"}],
            components=[{"name": "CI"}],
        )

        logging.info(f"Created ({new_issue.key}) {new_issue.fields.summary}")
        return new_issue

    def build_failure(self):
        dry_run = self.args.dry_run
        commit = os.getenv("CI_COMMIT_SHORT_SHA", "commit_sha")
        log_analyzer = BuildLogAnalyzer(self.args.build_logs_dir)
        failures = log_analyzer.failures()

        issue = self.create_or_update_issue(
            "build", log_analyzer.failures_jira_string()
        )

        if not failures:
            return

        if not dry_run and not issue:
            return

        for failure in failures:
            filename = f"{failure.name}_{failure.step}_{commit}.log"

            if dry_run:
                logging.info(f"Would add attachment {filename} from {failure.path})")
                continue

            logging.info(f"Adding attachment {filename} from {failure.path})")
            self.jira.add_attachment(
                issue=issue, attachment=failure.path, filename=filename
            )


def main():
    logging.basicConfig(
        level=logging.INFO, format="%(levelname)7s: %(message)s", stream=sys.stderr
    )

    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--debug", action="store_true", help="enable debug mode")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Do not alter Jira content, just printout what would be done",
    )

    parser.add_argument(
        "--access-token",
        type=str,
        default=os.environ.get("JIRA_ACCESS_TOKEN"),
        help="Jira access token (default: %(default)s)",
    )

    parser.add_argument(
        "--access-token-secret",
        type=str,
        default=os.environ.get("JIRA_ACCESS_TOKEN_SECRET"),
        help="Jira access token secret",
    )

    parser.add_argument(
        "--consumer-key",
        type=str,
        default=os.environ.get("JIRA_CONSUMER_KEY"),
        help="Jira consumer key",
    )

    parser.add_argument(
        "--instance-url",
        type=str,
        default=os.environ.get("JIRA_INSTANCE_URL", "https://jira.prplfoundation.org"),
        help="Jira instance URL (default: %(default)s)",
    )

    parser.add_argument(
        "--private-key",
        type=str,
        default=os.environ.get("JIRA_PRIVATE_KEY"),
        help="Jira private key",
    )

    parser.add_argument(
        "--project",
        type=str,
        default=os.environ.get("JIRA_PROJECT", "PCF"),
        help="Jira target project (default: %(default)s)",
    )

    subparsers = parser.add_subparsers(dest="command", title="available subcommands")
    subparser = subparsers.add_parser("build_failure", help="report build failure")
    subparser.add_argument(
        "--build-logs-dir",
        type=str,
        default=os.path.join(os.getcwd(), "logs"),
        help="Path to directory which contains build logs",
    )
    subparser.set_defaults(func=JiraHelper.build_failure)

    args = parser.parse_args()

    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)

    if not args.command:
        print("command is missing")
        exit(1)

    prpl_jira = JiraHelper(args)
    args.func(prpl_jira)


if __name__ == "__main__":
    main()
