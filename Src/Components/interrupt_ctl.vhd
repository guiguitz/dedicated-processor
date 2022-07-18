
---- This code was obtained from: 
---- https://github.com/kevinpt/vhdl-extras/blob/master/rtl/extras/interrupt_ctl.vhdl
--------------------------------------------------------------------
--  _    __ __  __ ____   __   =                                  --
-- | |  / // / / // __ \ / /   =                                  --
-- | | / // /_/ // / / // /    =    .__  |/ _/_  .__   .__    __  --
-- | |/ // __  // /_/ // /___  =   /___) |  /   /   ) /   )  (_ ` --
-- |___//_/ /_//_____//_____/  =  (___  /| (_  /     (___(_ (__)  --
--                           =====     /                          --
--                            ===                                 --
-----------------------------  =  ----------------------------------
--# interrupt_ctl.vhdl - General purpose priority interrupt controller
--# Freely available from VHDL-extras (http://github.com/kevinpt/vhdl-extras)
--#
--# Copyright © 2014 Kevin Thibedeau
--# (kevin 'period' thibedeau 'at' gmail 'punto' com)
--#
--# Permission is hereby granted, free of charge, to any person obtaining a
--# copy of this software and associated documentation files (the "Software"),
--# to deal in the Software without restriction, including without limitation
--# the rights to use, copy, modify, merge, publish, distribute, sublicense,
--# and/or sell copies of the Software, and to permit persons to whom the
--# Software is furnished to do so, subject to the following conditions:
--#
--# The above copyright notice and this permission notice shall be included in
--# all copies or substantial portions of the Software.
--#
--# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
--# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
--# DEALINGS IN THE SOFTWARE.
--#
--# DEPENDENCIES: none
--#
--# DESCRIPTION:
--#  This package provides a general purpose interrupt controller that handles
--#  the management of multiple interrupt sources. It uses unconstrained arrays
--#  to specify the interrupt vector signals. It can thus be sized as needed to
--#  suit required number of interrupts.
--#
--#  The priority of the interrupts is fixed with the lowest index having the
--#  highest priority. You can use ascending or descending ranges for the
--#  control vectors. Multiple pending interrupts are serviced from highest to
--#  lowest priority. If a higher priority interrupt arrives when a lower
--#  priority interrupt is currently in service, the higher priority interrupt
--#  takes effect after the lower interrupt is acknowledged. If you disable a
--#  pending interrupt with its mask it will not return after reenabling the
--#  mask bit until the next interrupt arrives.
--#
--#  EXAMPLE USAGE:
--#
--#  -- Create an 8-bit interrupt controller
--#  signal int_mask, int_request, pending_int, current_int :
--#         std_ulogic_vector(7 downto 0);
--#  ...
--#  -- Disable interrupts 5, 6, and 7
--#  int_mask <= (7 downto 5 => '0', others => '1');
--#  ic: interrupt_ctl
--#    port map (
--#      Clock => clock,
--#      Reset => reset,
--#
--#      Int_mask    => int_mask,      -- Mask to enable/disable interrupts
--#      Int_request => int_request,   -- Interrupt sources
--#      Pending     => pending_int,   -- Current set of pending interrupts
--#      Current     => current_int,   -- Vector identifying which interrupt is active
--#
--#      Interrupt     => interrupt,     -- Signal when an interrupt is pending
--#      Acknowledge   => interrupt_ack, -- Acknowledge the interrupt has been serviced
--#      Clear_pending => clear_pending  -- Optional control to clear all
--#    );
--#
--#  -- Assemble interrupt sources into a request vector
--#  int_request <= (
--#    0 => source1, -- Highest priority
--#    1 => source2,
--#    2 => source3,
--#    3 => source4, -- Lowest priority
--#    others => '0'); -- The remaining sources are unused
--------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE interrupt_ctl_pkg IS
    --## Priority interrupt controller.
    COMPONENT interrupt_ctl IS
        GENERIC (
            RESET_ACTIVE_LEVEL : STD_LOGIC := '1' --# Asynch. reset control level
        );
        PORT (
            --# {{clocks|}}
            Clock : IN STD_LOGIC; --# System clock
            Reset : IN STD_LOGIC; --# Asynchronous reset

            --# {{control|}}
            Int_mask : IN STD_LOGIC_VECTOR; --# Set bits correspond to active interrupts
            Int_request : IN STD_LOGIC_VECTOR; --# Controls used to activate new interrupts
            Pending : OUT STD_LOGIC_VECTOR; --# Set bits indicate which interrupts are pending
            Current : OUT STD_LOGIC_VECTOR; --# Single set bit for the active interrupt

            Interrupt : OUT STD_LOGIC; --# Flag indicating when an interrupt is pending
            Acknowledge : IN STD_LOGIC; --# Clear the active interrupt
            Clear_pending : IN STD_LOGIC --# Clear all pending interrupts
        );
    END COMPONENT;
END PACKAGE;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY interrupt_ctl IS
    GENERIC (
        RESET_ACTIVE_LEVEL : STD_LOGIC := '1' --# Asynch. reset control level
    );
    PORT (
        --# {{clocks|}}
        Clock : IN STD_LOGIC; --# System clock
        Reset : IN STD_LOGIC; --# Asynchronous reset

        --# {{control|}}
        Int_mask : IN STD_LOGIC_VECTOR; --# Set bits correspond to active interrupts
        Int_request : IN STD_LOGIC_VECTOR; --# Controls used to activate new interrupts
        Pending : OUT STD_LOGIC_VECTOR; --# Set bits indicate which interrupts are pending
        Current : OUT STD_LOGIC_VECTOR; --# Single set bit for the active interrupt

        Interrupt : OUT STD_LOGIC; --# Flag indicating when an interrupt is pending
        Acknowledge : IN STD_LOGIC; --# Clear the active interrupt
        Clear_pending : IN STD_LOGIC --# Clear all pending interrupts
    );
END ENTITY;

ARCHITECTURE rtl OF interrupt_ctl IS
    SIGNAL pending_loc, current_loc : STD_LOGIC_VECTOR(Int_request'RANGE);
    SIGNAL interrupt_loc : STD_LOGIC;

    -- Priority decoder
    -- Input is a vector of all pending interrupts. Result is a vector with just the
    -- highest priority interrupt bit set.
    FUNCTION priority_decode(pending_v : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result : STD_LOGIC_VECTOR(pending_v'RANGE);
        VARIABLE or_chain : STD_LOGIC;
    BEGIN
        -- Lowest bit has highest priority
        result(pending_v'low) := pending_v(pending_v'low);
        or_chain := result(pending_v'low);

        -- Loop through looking for the highest priority interrupt that is pending
        FOR i IN pending_v'low + 1 TO pending_v'high LOOP
            IF pending_v(i) = '1' AND or_chain = '0' THEN
                result(i) := '1';
            ELSE
                result(i) := '0';
            END IF;
            or_chain := or_chain OR pending_v(i);
        END LOOP;

        RETURN result;
    END FUNCTION;

    -- OR-reduce for compatibility with VHDL-93
    FUNCTION or_reduce(vec : STD_LOGIC_VECTOR) RETURN STD_LOGIC IS
        VARIABLE or_chain : STD_LOGIC;
    BEGIN
        or_chain := '0';
        FOR i IN vec'RANGE LOOP
            or_chain := or_chain OR vec(i);
        END LOOP;

        RETURN or_chain;
    END FUNCTION;

BEGIN

    ic : PROCESS (Clock, Reset) IS
        VARIABLE clear_int_n, pending_v, current_v : STD_LOGIC_VECTOR(pending'RANGE);
        VARIABLE interrupt_v : STD_LOGIC;
    BEGIN

        -- Embedded checks
        ASSERT Int_request'length >= 2
        REPORT "Interrupt priority decoder must have at least two inputs" SEVERITY failure;
        ASSERT Int_mask'length = Int_request'length
        REPORT "Int_mask length must match Int_request" SEVERITY failure;
        ASSERT Pending'length = Int_request'length
        REPORT "Pending length must match Int_request" SEVERITY failure;
        ASSERT Current'length = Int_request'length
        REPORT "Current length must match Int_request" SEVERITY failure;

        -- interrupt_ctl logic
        IF Reset = RESET_ACTIVE_LEVEL THEN

            pending_loc <= (OTHERS => '0');
            current_loc <= (OTHERS => '0');
            interrupt_loc <= '0';

        ELSIF rising_edge(Clock) THEN

            IF Clear_pending = '1' THEN -- Clear all
                clear_int_n := (OTHERS => '0');
            ELSIF Acknowledge = '1' THEN -- Clear the pending interrupt
                clear_int_n := NOT current_loc;
            ELSE -- Clear nothing
                clear_int_n := (OTHERS => '1');
            END IF;

            -- Keep track of pending interrupts while disabling inactive interrupts
            -- and clearing acknowledged interrupts.
            pending_v := (Int_request OR pending_loc) AND Int_mask AND clear_int_n;
            pending_loc <= pending_v;

            -- Determine the active interrupt from among those pending
            current_v := priority_decode(pending_v);

            -- Flag when any active interrupt is pending
            interrupt_v := or_reduce(current_v);
            interrupt_loc <= interrupt_v;

            IF interrupt_loc = '0' OR (interrupt_loc = '1' AND Acknowledge = '1') THEN
                -- Update current interrupt
                current_loc <= current_v;
            END IF;

        END IF;
    END PROCESS;

    Current <= current_loc;
    Pending <= pending_loc;
    Interrupt <= interrupt_loc;
END ARCHITECTURE;
