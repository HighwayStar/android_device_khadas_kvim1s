#
# Copyright (C) 2021 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ifneq ($(filter kvim1s kvim1s_car kvim1s_tab,$(TARGET_DEVICE)),)

LOCAL_PATH := device/khadas/kvim1s
FACTORY_PATH := device/khadas/kvim1s/factory

RADIO_FILES := $(wildcard $(FACTORY_PATH)/bootfiles/*)
$(foreach f, $(notdir $(RADIO_FILES)), \
    $(call add-radio-file,factory/bootfiles/$(f)))

PRODUCT_INSTALL_OUT := $(PRODUCT_OUT)/aml_install
PRODUCT_UPGRADE_OUT := $(PRODUCT_OUT)/aml_upgrade
INSTALL_PACKAGE_CONFIG_FILE := $(PRODUCT_INSTALL_OUT)/image_install.cfg
UPGRADE_PACKAGE_CONFIG_FILE := $(PRODUCT_UPGRADE_OUT)/image_upgrade.cfg
AML_IMAGE_TOOL := $(FACTORY_PATH)/aml_image_v2_packer

INSTALLED_AML_INSTALL_PACKAGE_TARGET := $(PRODUCT_OUT)/aml_install_package.img
INSTALLED_AML_UPGRADE_PACKAGE_TARGET := $(PRODUCT_OUT)/aml_upgrade_package.img

define aml-copy-install-file
	$(hide) $(ACP) $(1) $(PRODUCT_INSTALL_OUT)/$(strip $(if $(2), $(2), $(notdir $(1))))
endef

define aml-copy-upgrade-file
	$(hide) $(ACP) $(1) $(PRODUCT_UPGRADE_OUT)/$(strip $(if $(2), $(2), $(notdir $(1))))
endef


UPGRADE_IMAGES := \
    logo.img \
    boot.img \
    super.img \
    super_empty.img \
    vbmeta.img \
    vbmeta_system.img \
    vendor_boot.img \
    dtbo.img \
    dtb.PARTITION

INSTALL_IMAGES := \
    boot.img \
    dtbo.img \
    vbmeta.img \
    dtb.PARTITION \
    vbmeta_system.img \
    vendor_boot.img \
    super.img \
    super_empty.img \
    logo.img \
    misc.img



$(INSTALLED_AML_INSTALL_PACKAGE_TARGET): $(addprefix $(PRODUCT_OUT)/,$(INSTALL_IMAGES)) $(ACP) $(AML_IMAGE_TOOL)
	$(hide) mkdir -p $(PRODUCT_INSTALL_OUT)
ifeq ($(WITH_CONSOLE_BL),true)
	$(hide) $(call aml-copy-install-file, $(FACTORY_PATH)/bootfiles/bootloader-console.img, u-boot.bin)
else
	$(hide) $(call aml-copy-install-file, $(FACTORY_PATH)/bootfiles/bootloader.img, u-boot.bin)
endif
	$(hide) $(call aml-copy-install-file, $(FACTORY_PATH)/bootfiles/aml_sdc_burn.UBOOT)
	$(hide) $(call aml-copy-install-file, $(FACTORY_PATH)/bootfiles/DDR.USB)
	$(hide) $(call aml-copy-install-file, $(PRODUCT_OUT)/logo.img)
	$(hide) $(call aml-copy-install-file, $(FACTORY_PATH)/aml_sdc_burn.ini)
	$(hide) $(call aml-copy-install-file, $(FACTORY_PATH)/usb_flow.aml)
	$(hide) $(call aml-copy-install-file, $(FACTORY_PATH)/image_install.cfg, image.cfg)
	$(hide) $(call aml-copy-install-file, $(FACTORY_PATH)/platform.conf)
	$(hide) $(call aml-copy-install-file, $(PRODUCT_OUT)/boot.img)
	$(hide) $(call aml-copy-install-file, $(PRODUCT_OUT)/dtb.img)
	$(hide) $(call aml-copy-install-file, $(PRODUCT_OUT)/dtbo.img)
	$(hide) $(call aml-copy-install-file, $(PRODUCT_OUT)/super_empty.img, super.img)
	$(hide) $(call aml-copy-install-file, $(PRODUCT_OUT)/vbmeta.img)
	$(hide) $(call aml-copy-install-file, $(PRODUCT_OUT)/vbmeta_system.img)
	$(hide) $(call aml-copy-install-file, $(PRODUCT_OUT)/vendor_boot.img)
	$(hide) $(call aml-copy-install-file, $(PRODUCT_OUT)/misc.img)
	$(hide) $(AML_IMAGE_TOOL) -r  $(PRODUCT_INSTALL_OUT)/image.cfg $(PRODUCT_INSTALL_OUT)/ $@
	$(hide) rm -rf $(PRODUCT_INSTALL_OUT)
	$(hide) echo " $@ created"

.PHONY: aml_install
aml_install: $(INSTALLED_AML_INSTALL_PACKAGE_TARGET)

BUILT_TARGET_FILES_ZIPROOT := $(call intermediates-dir-for,PACKAGING,target_files)/$(TARGET_PRODUCT)-target_files
$(BUILT_TARGET_FILES_ZIPROOT).zip: $(BUILT_TARGET_FILES_ZIPROOT)/IMAGES/aml_install_package.img

$(BUILT_TARGET_FILES_ZIPROOT)/IMAGES/aml_install_package.img: $(BUILT_TARGET_FILES_ZIPROOT).zip.list $(PRODUCT_OUT)/aml_install_package.img
	@mkdir -p $(dir $@)
	@cp $(PRODUCT_OUT)/aml_install_package.img $@
	@echo $@ >> $(BUILT_TARGET_FILES_ZIPROOT).zip.list

INSTALLED_RADIOIMAGE_TARGET += $(INSTALLED_AML_INSTALL_PACKAGE_TARGET)

$(INSTALLED_AML_UPGRADE_PACKAGE_TARGET): $(addprefix $(PRODUCT_OUT)/,$(UPGRADE_IMAGES)) $(ACP) $(AML_IMAGE_TOOL)
	$(hide) mkdir -p $(PRODUCT_UPGRADE_OUT)
ifeq ($(WITH_CONSOLE_BL),true)
	$(hide) $(call aml-copy-upgrade-file, $(FACTORY_PATH)/bootfiles/bootloader-console.img, bootloader.img)
else
	$(hide) $(call aml-copy-upgrade-file, $(FACTORY_PATH)/bootfiles/bootloader.img, bootloader.img)
endif
	$(hide) $(call aml-copy-upgrade-file, $(PRODUCT_OUT)/logo.img)
	$(hide) $(call aml-copy-upgrade-file, $(FACTORY_PATH)/bootfiles/aml_sdc_burn.UBOOT)
	$(hide) $(call aml-copy-upgrade-file, $(FACTORY_PATH)/bootfiles/DDR.USB)
	$(hide) $(call aml-copy-upgrade-file, $(FACTORY_PATH)/aml_sdc_burn.ini)
	$(hide) $(call aml-copy-upgrade-file, $(FACTORY_PATH)/usb_flow.aml)
	$(hide) $(call aml-copy-upgrade-file, $(FACTORY_PATH)/image_upgrade.cfg, image.cfg)
	$(hide) $(call aml-copy-upgrade-file, $(FACTORY_PATH)/platform.conf)
	$(hide) $(call aml-copy-upgrade-file, $(FACTORY_PATH)/odm_ext_a.PARTITION)
	$(hide) $(call aml-copy-upgrade-file, $(FACTORY_PATH)/oem_a.PARTITION)
	$(hide) $(call aml-copy-upgrade-file, $(PRODUCT_OUT)/boot.img)
	$(hide) $(call aml-copy-upgrade-file, $(PRODUCT_OUT)/dtb.PARTITION)
	$(hide) $(call aml-copy-upgrade-file, $(PRODUCT_OUT)/dtbo.img)
	$(hide) $(call aml-copy-upgrade-file, $(PRODUCT_OUT)/super.img)
	$(hide) $(call aml-copy-upgrade-file, $(PRODUCT_OUT)/vbmeta.img)
	$(hide) $(call aml-copy-upgrade-file, $(PRODUCT_OUT)/vbmeta_system.img)
	$(hide) $(call aml-copy-upgrade-file, $(PRODUCT_OUT)/vendor_boot.img)
	$(hide) $(AML_IMAGE_TOOL) -r  $(PRODUCT_UPGRADE_OUT)/image.cfg $(PRODUCT_UPGRADE_OUT)/ $@
	$(hide) rm -rf $(PRODUCT_UPGRADE_OUT)
	$(hide) echo " $@ created"

.PHONY: aml_upgrade
aml_upgrade: $(INSTALLED_AML_UPGRADE_PACKAGE_TARGET)

$(BUILT_TARGET_FILES_DIR): $(INSTALLED_RADIOIMAGE_TARGET)

endif
