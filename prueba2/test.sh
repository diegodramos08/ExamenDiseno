#!/bin/bash

iverilog -t vvp ./MultS4Bits.v ./MultU4Bits.v ./MultS4Bits_tb.v #-o MultS4Bits
if [ $? -ne 0 ]; then
    exit 1
fi

./a.out
#./MultS4Bits
