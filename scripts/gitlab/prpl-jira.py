#!/usr/bin/env python3

import sys
import os
import logging
import argparse

from jira import JIRA


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

    def build_failure(self):
        args = self.args
        job = os.getenv("CI_JOB_NAME", "job")
        project = os.getenv("CI_PROJECT_NAME", "project")
        project_url = os.getenv("CI_PROJECT_URL", "https://project_url")
        branch = os.getenv("CI_COMMIT_BRANCH", "branch")
        job_url = os.getenv("CI_JOB_URL", "https://job_url")
        commit = os.getenv("CI_COMMIT_SHORT_SHA", "commit_sha")
        commit_message = os.getenv("CI_COMMIT_MESSAGE", "foor bar baz")

        summary = f"CI build failure in {project}/{branch} during {job}"

        description = (
            f"Just noticed build failure during execution of "
            f"[{job}|{job_url}] job in _{project}/{branch}_ which is now at "
            f"[{commit}|{project_url}/-/commit/{commit}] commit:"
            "{noformat}"
            f"{commit_message}"
            "{noformat}"
        )

        jql = f"""
            project={args.project} AND resolution = Unresolved AND summary ~ '{summary}'
        """
        existing_issue = self.jira.search_issues(jql, maxResults=1)
        if existing_issue:
            existing_issue = self.jira.issue(existing_issue[0].key)
            logging.info(
                f"Updating ({existing_issue.key}) {existing_issue.fields.summary}"
            )
            self.jira.add_comment(existing_issue, description)
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


def main():
    logging.basicConfig(
        level=logging.INFO, format="%(levelname)7s: %(message)s", stream=sys.stderr
    )

    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--debug", action="store_true", help="enable debug mode")

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
