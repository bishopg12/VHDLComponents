-------------------------------------------------------------------------------
-- Title      : tmp108
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tmp108.vhd
-- Author     :   <bisho@STBERNARD>
-- Company    : 
-- Created    : 2021-02-07
-- Last update: 2021-02-09
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-02-07  1.0      bisho	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tmp108 is
  generic (
    Address : std_logic_vector(6 downto 0) := "1001000";
    Vdd : real := 3.3);
  
  port (
    temperature : integer range -55 to 128 := 0;
    anAlert : out std_logic;
    Scl : in std_logic;
    sSda : inout std_logic);
end entity tmp108;

architecture behavioral of tmp108 is

  type tSlave is (IdleSt, StartSt, WtSlaveAddrSt, WtReadNWriteSt, WtSlaveAddrAckSt,
                  WtPointerSt, WtPointerAckSt, WtHighByteSt, WtHighByteAckSt,
                  WtLowByteSt, WtLowByteAckSt, RdSlaveAddrSt, RdReadNWriteSt,
                  RdSlaveAddrAckSt, RdHighByteSt, RdHighByteAckSt,
                  RdLowByteSt, RdLowByteAckSt, StopSt);

  signal TSclLowFast : time := 1300 ns;
  signal TSclLowHighSpeed : time := 0;
  signal TSclHighFast : time := 600 ns;
  signal TSclHighHighSpeed : time := 60 ns;

  signal TSdaHoldMin : time := 0 ns;
  signal TSdaHoldMaxFast : time := 900 ns;
  signal TSdaHoldMaxHighSpeed : time := 0 ns;

  signal TBufFast : time := 1300 ns;
  signal TBufHighSpeed : time := 0 ns;
  
  signal TSdaSetupMinFast : time := 100 ns;
  signal TSdaSetupMinHighSpeed : time := 0 ns;
  signal HighSpeed : boolean := false;
begin

  TSclLowHighSpeed <= 160 ns when Vdd >= 1.8 else
                       260 ns;

  TSdaHoldMaxHighSpeed <= 70 ns when Vdd >= 1.8 else
                          130 ns;

  TSdaSetupMinHighSpeed <= 10 ns when Vdd >= 1.8 else
                           50 ns;

  TBufHighSpeed <= 160 ns when vdd >= 1.8 else
                   260 ns;
  
  CheckSclParametersProc : process(Scl)
  begin
    if rising_edge(Scl) then
      if HighSpeed = false then
        assert Scl'stable(TSclLowFast)
          report "Scl low time violation" severity error;
      else
        assert Scl'stable(TSclLowHighSpeed)
          report "Scl low time violation" severity error;
      end if;
    end if;
    if falling_edge(Scl) then
      if HighSpeed = false then
        assert Scl'stable(TSclHighFast)
          report "Scl high time violation" severity error;
      else
        assert Scl'stable(TSclHighHighSpeed)
          report "Scl high time violation" severity error;
      end if;
  end CheckSclParametersProc;
  
  CheckSdaParametersProc : process(Scl)
  begin
    -- Check setup timing
    if rising_edge(Scl) then
      if HighSpeed = false then
        assert Sda'stable(TSdaSetupMinFast)
          report "Sda setup violation" severity error;
      else
        assert Sda'stable(TSdaSetupMinHighSpeed)
          report "Sda setup violation" severity error;
      end if;
    end if;

    -- Check hold timing
    if Sda'event then
      if Scl = '0' then
        if HighSpeed = false then
          assert Scl'last_event >= TSdaHoldMin and Scl'last_event <= TSdaHoldMaxFast
            report "Sda hold violation" severity error;
        else
          assert Scl'last_event >= TSdaHoldMin and Scl'last_event <= TSdaHoldMaxHighSpeed
            report "Sda hold violation" severity error;
        end if;
      else
        if Sda = '0' then
          if HighSpeed = false then
            assert Scl'stable(TBufFast)
              report "Bus free time violation" severity error;
          else
            assert Scl'stable(TBufHighSpeed)
              report "Bus free time violation" severity error;
          end if;
        end if;
      end if;
    end if;
  end CheckSdaParametersProc;
  


  StateMachineProc: process
  begin
    
  end StateMachineProc;
  
end behavioral;
