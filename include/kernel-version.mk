# Use the default kernel version if the Makefile doesn't override it

LINUX_RELEASE?=1

ifdef CONFIG_TESTING_KERNEL
  KERNEL_PATCHVER:=$(KERNEL_TESTING_PATCHVER)
endif

LINUX_VERSION-4.4 = .60
LINUX_VERSION-4.9 = .184
LINUX_VERSION-4.14 = .180
LINUX_VERSION-4.19 = .101
LINUX_VERSION-5.4 = .60

LINUX_KERNEL_HASH-4.4.60 = 7f0c3bf4257326f9d074a83d688be589f210b5a8d69d67f88615adca9b61d960
LINUX_KERNEL_HASH-4.9.184 = 033114d5350525dede995d31b596c31b0e26db8d77a0a1c53d36cdc36ead9faf
LINUX_KERNEL_HASH-4.14.180 = 444ef973d9b6a6ea174e4a9086f0aea980d8575d13302e431ad688f22e27ed0e
LINUX_KERNEL_HASH-4.19.101 = be26156abdb38ac0576a34a235ef456bb8ca67fbbe56fc6649b8d069159f8bc4
LINUX_KERNEL_HASH-5.4.60 = add2ab2385c40fc9a3dfebe403e56da8500b633dc7dc42cf0c670c61d151a223

remove_uri_prefix=$(subst git://,,$(subst http://,,$(subst https://,,$(1))))
sanitize_uri=$(call qstrip,$(subst @,_,$(subst :,_,$(subst .,_,$(subst -,_,$(subst /,_,$(1)))))))

ifneq ($(call qstrip,$(CONFIG_KERNEL_GIT_CLONE_URI)),)
  LINUX_VERSION:=$(call sanitize_uri,$(call remove_uri_prefix,$(CONFIG_KERNEL_GIT_CLONE_URI)))
  ifeq ($(call qstrip,$(CONFIG_KERNEL_GIT_REF)),)
    CONFIG_KERNEL_GIT_REF:=HEAD
  endif
  LINUX_VERSION:=$(LINUX_VERSION)-$(call sanitize_uri,$(CONFIG_KERNEL_GIT_REF))
else
ifdef KERNEL_PATCHVER
  LINUX_VERSION:=$(KERNEL_PATCHVER)$(strip $(LINUX_VERSION-$(KERNEL_PATCHVER)))
endif
ifdef KERNEL_TESTING_PATCHVER
  LINUX_TESTING_VERSION:=$(KERNEL_TESTING_PATCHVER)$(strip $(LINUX_VERSION-$(KERNEL_TESTING_PATCHVER)))
endif
endif

split_version=$(subst ., ,$(1))
merge_version=$(subst $(space),.,$(1))
KERNEL_BASE=$(firstword $(subst -, ,$(LINUX_VERSION)))
KERNEL=$(call merge_version,$(wordlist 1,2,$(call split_version,$(KERNEL_BASE))))
KERNEL_PATCHVER ?= $(KERNEL)

# disable the md5sum check for unknown kernel versions
LINUX_KERNEL_HASH:=$(LINUX_KERNEL_HASH-$(strip $(LINUX_VERSION)))
LINUX_KERNEL_HASH?=x
