#!/bin/bash -Eeu

mkdir cdl && cd cdl
go mod init cdl-go-testify
go get github.com/stretchr/testify
go mod download all
go mod tidy