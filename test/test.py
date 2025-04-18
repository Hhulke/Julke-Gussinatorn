# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import random


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 0

    dut._log.info("Test project behavior")

    # Set the input values you want to test

    # Wait for one clock cycle to see the output values
    for l in range(3):
        for i in range(3):
            await ClockCycles(dut.clk, random.randint(5,43))
            dut.ui_in.value = 2
            await ClockCycles(dut.clk, 100)
            dut.ui_in.value = 0
            await ClockCycles(dut.clk, 100)

        await ClockCycles(dut.clk, 100)
        dut.ui_in.value = 4

    await ClockCycles(dut.clk, 100)
    dut.ui_in.value = 8

    await ClockCycles(dut.clk, 100000)

    await ClockCycles(dut.clk, 100000)

    await ClockCycles(dut.clk, 100)

    for l in range(3):
        for i in range(3):
            await ClockCycles(dut.clk, random.randint(5,43))
            dut.ui_in.value = random.randint(1,2)
            await ClockCycles(dut.clk, 100)
            dut.ui_in.value = 0
            await ClockCycles(dut.clk, 100)

        await ClockCycles(dut.clk, 100)
        dut.ui_in.value = 4

    await ClockCycles(dut.clk, 100)
    dut.ui_in.value = 8

    await ClockCycles(dut.clk, 100000)

    dut.ui_in.value = 0

    await ClockCycles(dut.clk, 100000)

    await ClockCycles(dut.clk, 100)
    dut.ui_in.value = 16

    await ClockCycles(dut.clk, 100000)

    await ClockCycles(dut.clk, 100000)

    dut.ui_in.value = 0

    await ClockCycles(dut.clk, 100)

    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 100)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
