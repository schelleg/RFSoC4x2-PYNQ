# Copyright (C) 2022 Xilinx, Inc
# SPDX-License-Identifier: BSD-3-Clause

PREBUILT_ROOTFS_DST := ${CURDIR}/pynq/sdbuild/prebuilt/pynq_rootfs.aarch64.tar.gz
PREBUILT_SDIST_DST := ${CURDIR}/pynq/sdbuild/prebuilt/pynq_sdist.tar.gz
BSP_DST := ${CURDIR}/boards/${BOARD}/${BOARD}.bsp

BASE_OVERLAY_PATH := ${CURDIR}/boards/${BOARD}/base
BASE_OVERLAY := ${BASE_OVERLAY_PATH}/base.bit

VERSION := 3.0.0
IMAGE := ${BOARD}-${VERSION}.img

all: checkenv_rfsocpynq gitsubmodule ${PREBUILT_SDIST_DST} ${PREBUILT_ROOTFS_DST} checkenv_pynq ${BASE_OVERLAY} ${IMAGE}
	@echo ""
	@echo "  RFSoC-PYNQ completed building image: ${IMAGE}"
	@echo ""

gitsubmodule:
	# git submodule init && git submodule update

checkenv_rfsocpynq:
ifeq ($(BOARD),)
	$(error Please set board variable BOARD when calling this Makefile)
endif

ifeq ($(wildcard $(BSP_DST)),)
ifneq ($(BOARD),RFSoC2x2)
	$(error Please copy $(BOARD) BSP to $(BSP_DST) - see README for download instructions)
endif
endif

${PREBUILT_SDIST_DST}:
	wget https://github.com/Xilinx/pynq/releases/download/v2.7.0/pynq-2.7.0.tar.gz -O ${PREBUILT_SDIST_DST}

${PREBUILT_ROOTFS_DST}:
	wget https://bit.ly/pynq_aarch64_2_7 -O ${PREBUILT_ROOTFS_DST}

checkenv_pynq:
	${CURDIR}/pynq/sdbuild/scripts/check_env.sh

${BASE_OVERLAY}:
ifneq ($(wildcard $(BASE_OVERLAY_PATH)),)
	cd ${CURDIR}/boards/${BOARD}/base && make
endif

${IMAGE}: 
	cd ${CURDIR}/pynq/sdbuild && make BOARDDIR=${CURDIR}/boards BOARDS=${BOARD}
	mv ${CURDIR}/pynq/sdbuild/output/${BOARD}*.img ${IMAGE}
