#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=kvim1s
export DEVICE_COMMON=ne-common
export VENDOR=khadas
export VENDOR_BRAND=khadas
export VENDOR_COMMON=amlogic

"./../../${VENDOR_COMMON}/${DEVICE_COMMON}/extract-files.sh" "$@"
