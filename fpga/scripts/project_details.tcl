# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name KeyboardHero_Master

# Top module name                               -- EDIT
set top_module top_master_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_master_basys3.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/core/master_fsm.sv
    ../rtl/core/button_decoder.sv
    ../rtl/core/input_synch.sv
    ../rtl/core/game_pkg.sv
    ../rtl/core/game_engine.sv
    ../rtl/core/timer.sv
    ../rtl/core/UART_mux.sv
    ../rtl/core/song_rom.sv
    ../rtl/core/top_master.sv
    ../rtl/core/damped_comb.sv
    ../rtl/sound/sound_pkg.sv
    ../rtl/sound/bclk_gen.sv
    ../rtl/sound/lrclk_gen.sv
    ../rtl/sound/phase_inc_rom.sv
    ../rtl/sound/phase_acc_note.sv
    ../rtl/sound/mixer.sv
    ../rtl/sound/sdata_gen.sv
    ../rtl/sound/sine_rom.sv
    ../rtl/sound/sound_fsm.sv
    ../rtl/sound/record_rom.sv
    ../rtl/sound/record_player.sv
    ../rtl/sound/sound_top.sv
    rtl/top_master_basys3.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    ../rtl/uart/uart.v
    ../rtl/uart/uart_rx.v
    ../rtl/uart/uart_tx.v
    ../rtl/uart/fifo.v
    ../rtl/uart/mod_m_counter.v
    rtl/clk_wiz_0_clk_wiz.v
}

# Specify VHDL design files location            -- EDIT
set vhdl_files {
   rtl/Ps2Interface.vhd
}

# Specify files for a memory initialization     -- EDIT
set mem_files {
    ../rtl/core/songs/song_0.data
    ../rtl/core/songs/song_1.data
    ../rtl/core/songs/song_2.data
    ../rtl/core/songs/song_3.data
    ../rtl/sound/music/track_0.data
    ../rtl/sound/music/track_1.data
    ../rtl/sound/music/track_2.data
    ../rtl/sound/music/track_3.data
}
