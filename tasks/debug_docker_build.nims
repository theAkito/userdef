#!/usr/bin/env nim
mode = ScriptMode.Silent
switch("hints", "off")

import
  os,
  strformat,
  strutils

const
  tagVerPrefix   = ':'
  tagVerSuffix   = '-'
  platforms      = "linux/amd64,linux/i386,linux/arm64,linux/arm/v7,linux/arm32v5,linux/arm32v6,linux/arm32v7,linux/arm64v8"
  tagLatest      = "latest"
  tagDebug       = "debug"
  tagSuffixDebug = tagVerSuffix & tagDebug

var
  params = commandLineParams()[2..^1]
  version = params[0]
  tagRoot = "akito13/userdef"
  tag = if params.len > 1: params[1] else: ""

if tag.isEmptyOrWhitespace:
  tag = tagRoot & tagVerPrefix & version
else:
  tagRoot = tag.split(tagVerPrefix, 1)[0]

## Build Musl Image
exec &"""
docker \
  buildx \
  build \
    --no-cache \
    --platform "{platforms}" \
    --tag "{tag}{tagSuffixDebug}" \
    --tag "{tagRoot}{tagVerPrefix}{tagLatest}{tagSuffixDebug}" \
    --file debug.Dockerfile \
    --push \
  .
"""
