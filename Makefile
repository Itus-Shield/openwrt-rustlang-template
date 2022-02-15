# This is a Framework Template for a Rust-Lang enabled OpenWrt Package.
#
# Written: Donald Hoskins <grommish@gmail.com>, 2022
#
# Instructions:
#
# This assumes a Github-based Repository
#
# 1) Fill in The Blanks <>
# 2) Build/Compile is used to call cargo and/or rustc - See the below
#    example on how to use the variables and format
# 3) Save the Makefile, and run the following to update the feeds index:
#    ./scripts/feeds update -i
#    ./scripts/feeds install <pkg_name>
# 4) Call 'make package/feeds/packages/to/app/{download,check} FIXUP=1'
# 5) cargo packages typically do not have a ./configure step, so you
#    can leave that entire section blank.
# 6) Build/Compile is used to call cargo and/or rustc - See the below
#    example on how to use the variables and format
# 7) Be sure to run `make menuconfig` PRIOR to building, so that it updates the
#    dependencies.
#
#
# Notable Variables Used:
# CARGO_HOME - Sysroot where cargo/rustc is installed
# RUSTC_HOST_ARCH - The GNU/LLVM Tuple of the Build Host
# RUSTC_TARGET_ARCH/REAL_GNU_TARGET_NAME - The GNU/LLVM Tuple of the Target Device
# RUSTFLAGS - Additional Build Flags used by the Rust compiler
# TARGET_CONFIGURE_OPTS - Used to add CARGO_HOME Environmental

include $(TOPDIR)/rules.mk

PKG_NAME := <PACKAGE_NAME>
PKG_VERSION := <PACKAGE_VERSION>
PKG_RELEASE := 1

PKG_SOURCE_PROTO := git
PKG_SOURCE_DATE := <Commit Date>
PKG_SOURCE_VERSION := <Commit Hash>
PKG_SOURCE_URL := <Git Repo URL>
PKG_MIRROR_HASH := skip

PKG_BUILD_DEPENDS := rust/host

CARGO_HOME := $(STAGING_DIR_HOST)
TARGET_CONFIGURE_OPTS += CARGO_HOME="$(STAGING_DIR_HOST)"

# Uncomment below to enable Debug symbols (for use with remote-gdb)
# TARGET_CFLAGS += -ggdb3

include $(INCLUDE_DIR)/package.mk

CONFIG_HOST_SUFFIX:=$(shell cut -d"-" -f4 <<<"$(GNU_HOST_NAME)")
RUSTC_HOST_ARCH:=$(HOST_ARCH)-unknown-linux-$(CONFIG_HOST_SUFFIX)
RUSTC_TARGET_ARCH:=$(REAL_GNU_TARGET_NAME)

CONFIGURE_VARS += \
        CARGO_HOME="$(CARGO_HOME)" \
        ac_cv_path_CARGO="$(STAGING_DIR_HOST)/bin/cargo" \
        ac_cv_path_RUSTC="$(STAGING_DIR_HOST)/bin/rustc" \
        RUSTFLAGS="-C linker=$(TARGET_CC_NOCACHE) -C ar=$(TARGET_AR)"

CONFIGURE_ARGS += \
  	--host=$(REAL_GNU_TARGET_NAME)

define Build/Compile
        cd $(PKG_BUILD_DIR) && $(TARGET_CONFIGURE_OPTS) $(CONFIGURE_VARS) cargo update && \
	  $(TARGET_CONFIGURE_OPTS) $(CONFIGURE_VARS) cargo build -v --release \
	  --target $(REAL_GNU_TARGET_NAME) --features 'pcre2'
endef

define Package/$(PKG_NAME)
    SECTION:=<Section>
    CATEGORY:=<Category>
    DEPENDS:=@!SMALL_FLASH @!LOW_MEMORY_FOOTPRINT
    TITLE:=<Package TItle>
    URL:=<URL>
endef

define Package/$(PKG_NAME)/description
<Package Long Description>
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(REAL_GNU_TARGET_NAME)/release/<bin> $(1)/bin/<bin>
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
