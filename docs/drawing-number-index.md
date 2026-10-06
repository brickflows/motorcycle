# Motorcycle Build - Drawing Number Index (PROPOSED)

Generated 2026-09-03 from `C:\Users\micheal\Downloads\motorcyle`. **Planning pass only - nothing on disk was renamed or modified.**

- **192 documents**: 168 parts, 21 assemblies, 3 drawings

- **Scheme**: `MC-[TYPE]-[SEQ]`, SEQ zero-padded to 3 and incrementing per TYPE across the whole project, not per folder.

- **Sequencing basis**: file **creation date** (ascending), tie-broken alphabetically. See the caveat under *Sequencing* below.

- **Numbers are assigned to models.** A `.SLDDRW` inherits the number of the part or assembly it documents, so `foo.SLDPRT` and `foo.SLDDRW` share one DWG NO. rather than burning two.


## Type codes

Codes from your brief: `GER` `SFT` `HUB` `BRK` `PLT` `FRM`. `BRK` is unused - no bracket-type part appears in the project.


| Code | Meaning | Count |
|---|---|---|
| `ARM` | Arm | 11 |
| `ASM` | Assembly | 21 |
| `BAR` | Handlebar | 1 |
| `BAS` | Base | 1 |
| `BDG` | Bridge | 3 |
| `BDY` | Body | 4 |
| `BLB` | Bulb | 5 |
| `BLT` | Bolt / Screw | 17 |
| `BRG` | Bearing (incl. rings & balls) | 7 |
| `BSH` | Bushing | 3 |
| `CAP` | Cap | 2 |
| `CHN` | Chain Link | 4 |
| `CON` | Connector | 2 |
| `CSE` | Case / Housing | 12 |
| `DRM` | Drum | 1 |
| `FRM` | Frame Member | 7 |
| `GER` | Gear | 12 |
| `GRD` | Guard | 4 |
| `GRP` | Grip | 1 |
| `HUB` | Hub / Basket | 2 |
| `LNR` | Liner | 1 |
| `LVR` | Lever | 1 |
| `MAG` | Magnet | 1 |
| `MAN` | Manifold | 1 |
| `MIR` | Mirror | 1 |
| `MUF` | Muffler Section | 2 |
| `NUT` | Nut | 2 |
| `PIN` | Pin | 13 |
| `PIP` | Pipe | 3 |
| `PLG` | Plug | 4 |
| `PLT` | Plate | 7 |
| `PST` | Piston | 1 |
| `RAT` | Ratchet | 2 |
| `RIM` | Rim | 1 |
| `ROD` | Rod | 2 |
| `ROL` | Roller | 1 |
| `RST` | Foot Rest | 1 |
| `SCR` | Screen | 1 |
| `SFT` | Shaft | 11 |
| `SHK` | Shock Absorber Section | 2 |
| `SPK` | Sprocket | 4 |
| `SPR` | Spring | 3 |
| `TYR` | Tyre | 1 |
| `UNK` | UNCLASSIFIED | 2 |
| `VLV` | Valve | 1 |

## Proposed numbering

Sorted by folder to match the structure on disk.


| Current Filename | Folder | Inferred Type | Proposed DWG NO. | Proposed Title | Notes/Flags |
|---|---|---|---|---|---|
| `frame.SLDPRT` | `frame\01_Introduction - Motorcycle Frame` | FRM (Part) | **MC-FRM-001** | Motorcycle Main Frame | No drawing yet. |
| `left-side-engine-case.SLDPRT` | `frame\02_Left Side Engine Case` | CSE (Part) | **MC-CSE-001** | Left Side Engine Case | No drawing yet. |
| `right-side-engine-case.SLDDRW` | `frame\03_Right Side Engine Case` | CSE (Drawing) | **MC-CSE-002** | Right Side Engine Case | Drawing of the model above - inherits its number. Macro can write to this today. |
| `right-side-engine-case.SLDPRT` | `frame\03_Right Side Engine Case` | CSE (Part) | **MC-CSE-002** | Right Side Engine Case | **Drawing exists** - macro can write to it today. |
| `basket_gear_mced.SLDDRW` | `frame\04_Clutch Hub Parts` | GER (Drawing) | **MC-GER-001** | Basket Gear | Drawing of the model above - inherits its number. Macro can write to this today. |
| `basket_gear_mced.SLDPRT` | `frame\04_Clutch Hub Parts` | GER (Part) | **MC-GER-001** | Basket Gear | **Drawing exists** - macro can write to it today. |
| `clutch-hub-shaft-nut.SLDPRT` | `frame\04_Clutch Hub Parts` | NUT (Part) | **MC-NUT-002** | Clutch Hub Shaft Nut | No drawing yet. |
| `clutch-hub-steel-plate.SLDPRT` | `frame\04_Clutch Hub Parts` | PLT (Part) | **MC-PLT-007** | Clutch Hub Steel Plate | No drawing yet. |
| `clutch_hub_basket_mced.SLDDRW` | `frame\04_Clutch Hub Parts` | HUB (Drawing) | **MC-HUB-002** | Clutch Hub Basket | Drawing of the model above - inherits its number. Macro can write to this today. |
| `clutch_hub_basket_mced.SLDPRT` | `frame\04_Clutch Hub Parts` | HUB (Part) | **MC-HUB-002** | Clutch Hub Basket | **Drawing exists** - macro can write to it today. |
| `clutch_hub_friction_plate.SLDPRT` | `frame\04_Clutch Hub Parts` | PLT (Part) | **MC-PLT-001** | Clutch Hub Friction Plate | No drawing yet. |
| `clutch_hub_gear_bearing.SLDPRT` | `frame\04_Clutch Hub Parts` | BRG (Part) | **MC-BRG-001** | Clutch Hub Gear Bearing | Typed by noun head (`bearing`), not the `gear` in the name. No drawing yet. |
| `clutch_hub_gear_pin.SLDPRT` | `frame\04_Clutch Hub Parts` | PIN (Part) | **MC-PIN-001** | Clutch Hub Gear Pin | Typed by noun head (`pin`), not the `gear` in the name. No drawing yet. |
| `clutch_hub_gear_plate.SLDPRT` | `frame\04_Clutch Hub Parts` | PLT (Part) | **MC-PLT-002** | Clutch Hub Gear Plate | Typed by noun head (`plate`), not the `gear` in the name. No drawing yet. |
| `clutch_hub_inner_hub.SLDPRT` | `frame\04_Clutch Hub Parts` | HUB (Part) | **MC-HUB-001** | Clutch Hub Inner Hub | No drawing yet. |
| `clutch_hub_pressure_bolt.SLDPRT` | `frame\04_Clutch Hub Parts` | BLT (Part) | **MC-BLT-001** | Clutch Hub Pressure Bolt | No drawing yet. |
| `clutch_hub_pressure_plate.SLDPRT` | `frame\04_Clutch Hub Parts` | PLT (Part) | **MC-PLT-003** | Clutch Hub Pressure Plate | No drawing yet. |
| `clutch_hub_pressure_shaft.SLDPRT` | `frame\04_Clutch Hub Parts` | SFT (Part) | **MC-SFT-001** | Clutch Hub Pressure Shaft | No drawing yet. |
| `clutch_hub_pressure_spring.SLDPRT` | `frame\04_Clutch Hub Parts` | SPR (Part) | **MC-SPR-001** | Clutch Hub Pressure Spring | No drawing yet. |
| `clutch_hub_engine_case_mced.SLDPRT` | `frame\05_Clutch Hub Engine Case` | CSE (Part) | **MC-CSE-003** | Clutch Hub Engine Case | No drawing yet. |
| `input_shaft.SLDPRT` | `frame\06_Input Shaft Parts` | SFT (Part) | **MC-SFT-002** | Input Shaft | No drawing yet. |
| `input_shaft_gear_five.SLDPRT` | `frame\06_Input Shaft Parts` | GER (Part) | **MC-GER-002** | Input Shaft Gear Five | No drawing yet. |
| `input_shaft_gear_four.SLDPRT` | `frame\06_Input Shaft Parts` | GER (Part) | **MC-GER-003** | Input Shaft Gear Four | No drawing yet. |
| `input_shaft_gear_one.SLDPRT` | `frame\06_Input Shaft Parts` | GER (Part) | **MC-GER-005** | Input Shaft Gear One | No drawing yet. |
| `input_shaft_gear_three.SLDPRT` | `frame\06_Input Shaft Parts` | GER (Part) | **MC-GER-006** | Input Shaft Gear Three | No drawing yet. |
| `input_shaft_gear_two.SLDPRT` | `frame\06_Input Shaft Parts` | GER (Part) | **MC-GER-004** | Input Shaft Gear Two | No drawing yet. |
| `output_shaft.SLDPRT` | `frame\07_Output Shaft Parts` | SFT (Part) | **MC-SFT-003** | Output Shaft | No drawing yet. |
| `output_shaft_gear_five.SLDPRT` | `frame\07_Output Shaft Parts` | GER (Part) | **MC-GER-009** | Output Shaft Gear Five | No drawing yet. |
| `output_shaft_gear_four.SLDPRT` | `frame\07_Output Shaft Parts` | GER (Part) | **MC-GER-010** | Output Shaft Gear Four | No drawing yet. |
| `output_shaft_gear_one.SLDPRT` | `frame\07_Output Shaft Parts` | GER (Part) | **MC-GER-007** | Output Shaft Gear One | No drawing yet. |
| `output_shaft_gear_three.SLDPRT` | `frame\07_Output Shaft Parts` | GER (Part) | **MC-GER-008** | Output Shaft Gear Three | No drawing yet. |
| `output_shaft_gear_two.SLDPRT` | `frame\07_Output Shaft Parts` | GER (Part) | **MC-GER-011** | Output Shaft Gear Two | No drawing yet. |
| `output_shaft_sprocket.SLDPRT` | `frame\07_Output Shaft Parts` | SPK (Part) | **MC-SPK-001** | Output Shaft Sprocket | No drawing yet. |
| `crank_shaft.SLDPRT` | `frame\08_Crank Shaft Parts` | SFT (Part) | **MC-SFT-004** | Crank Shaft | No drawing yet. |
| `crank_shaft_gear_one.SLDPRT` | `frame\08_Crank Shaft Parts` | GER (Part) | **MC-GER-012** | Crank Shaft Gear One | No drawing yet. |
| `crank_shaft_sprocket.SLDPRT` | `frame\08_Crank Shaft Parts` | SPK (Part) | **MC-SPK-002** | Crank Shaft Sprocket | No drawing yet. |
| `stator_case.SLDPRT` | `frame\09_Stator Parts` | CSE (Part) | **MC-CSE-004** | Stator Case | No drawing yet. |
| `stator_engine_case.SLDPRT` | `frame\09_Stator Parts` | CSE (Part) | **MC-CSE-005** | Stator Engine Case | No drawing yet. |
| `stator_magnets.SLDPRT` | `frame\09_Stator Parts` | MAG (Part) | **MC-MAG-001** | Stator Magnets | No drawing yet. |
| `stator_nut.SLDPRT` | `frame\09_Stator Parts` | NUT (Part) | **MC-NUT-001** | Stator Nut | No drawing yet. |
| `shift_drum.SLDPRT` | `frame\10_Shift Drum Parts` | DRM (Part) | **MC-DRM-001** | Shift Drum | No drawing yet. |
| `shift_drum_gear_arms_pin.SLDPRT` | `frame\10_Shift Drum Parts` | PIN (Part) | **MC-PIN-002** | Shift Drum Gear Arms Pin | No drawing yet. |
| `shift_drum_placer_arm.SLDPRT` | `frame\10_Shift Drum Parts` | ARM (Part) | **MC-ARM-004** | Shift Drum Placer Arm | No drawing yet. |
| `shift_drum_ratchet_arm.SLDPRT` | `frame\10_Shift Drum Parts` | ARM (Part) | **MC-ARM-001** | Shift Drum Ratchet Arm | No drawing yet. |
| `shift_drum_transmission_arm.SLDPRT` | `frame\10_Shift Drum Parts` | ARM (Part) | **MC-ARM-002** | Shift Drum Transmission Arm | No drawing yet. |
| `shift_drum_transmission_arm_two.SLDPRT` | `frame\10_Shift Drum Parts` | ARM (Part) | **MC-ARM-003** | Shift Drum Transmission Arm Two | No drawing yet. |
| `transmission-shaft-foot-roller.SLDPRT` | `frame\11_Transmission Parts` | ROL (Part) | **MC-ROL-001** | Transmission Shaft Foot Roller | No drawing yet. |
| `transmission-shaft.SLDPRT` | `frame\11_Transmission Parts` | SFT (Part) | **MC-SFT-011** | Transmission Shaft | No drawing yet. |
| `transmission_pedal_plug.SLDPRT` | `frame\11_Transmission Parts` | PLG (Part) | **MC-PLG-001** | Transmission Pedal Plug | No drawing yet. |
| `transmission_ratchet_a.SLDPRT` | `frame\11_Transmission Parts` | RAT (Part) | **MC-RAT-001** | Transmission Ratchet A | No drawing yet. |
| `transmission_ratchet_b.SLDPRT` | `frame\11_Transmission Parts` | RAT (Part) | **MC-RAT-002** | Transmission Ratchet B | No drawing yet. |
| `cylinder_section_engine_case.SLDPRT` | `frame\12_Cylinder Section Engine Case and Engine Head Case` | CSE (Part) | **MC-CSE-007** | Cylinder Section Engine Case | No drawing yet. |
| `engine_head_case.SLDPRT` | `frame\12_Cylinder Section Engine Case and Engine Head Case` | CSE (Part) | **MC-CSE-006** | Engine Head Case | No drawing yet. |
| `valve-spring.SLDPRT` | `frame\13_Valve Section Engine Case and Valve Parts` | SPR (Part) | **MC-SPR-003** | Valve Spring | No drawing yet. |
| `valve.SLDPRT` | `frame\13_Valve Section Engine Case and Valve Parts` | VLV (Part) | **MC-VLV-001** | Valve | No drawing yet. |
| `valve_section_engine_case.SLDPRT` | `frame\13_Valve Section Engine Case and Valve Parts` | CSE (Part) | **MC-CSE-008** | Valve Section Engine Case | No drawing yet. |
| `Spark Plug.SLDPRT` | `frame\14-Spark Plugs` | PLG (Part) | **MC-PLG-004** | Spark Plug | No drawing yet. |
| `rocker_arm.SLDPRT` | `frame\15_Rocker Arm Parts` | ARM (Part) | **MC-ARM-005** | Rocker Arm | No drawing yet. |
| `rocker_shaft.SLDPRT` | `frame\15_Rocker Arm Parts` | SFT (Part) | **MC-SFT-005** | Rocker Shaft | No drawing yet. |
| `piston.SLDPRT` | `frame\16_Piston Parts` | PST (Part) | **MC-PST-001** | Piston | No drawing yet. |
| `piston_bolt.SLDPRT` | `frame\16_Piston Parts` | BLT (Part) | **MC-BLT-002** | Piston Bolt | No drawing yet. |
| `piston_bushing_Eng_Drw.SLDPRT` | `frame\16_Piston Parts` | BSH (Part) | **MC-BSH-001** | Piston Bushing | **FLAG** - `Eng_Drw` suffix is unusual; confirm it is the production part. No drawing yet. |
| `piston_pin.SLDPRT` | `frame\16_Piston Parts` | PIN (Part) | **MC-PIN-003** | Piston Pin | No drawing yet. |
| `piston_pin_plug.SLDPRT` | `frame\16_Piston Parts` | PLG (Part) | **MC-PLG-002** | Piston Pin Plug | No drawing yet. |
| `cam_chain_inner_mced.SLDPRT` | `frame\17_Cam Chain Parts` | CHN (Part) | **MC-CHN-001** | Cam Chain Inner | No drawing yet. |
| `cam_chain_outer_mced.SLDPRT` | `frame\17_Cam Chain Parts` | CHN (Part) | **MC-CHN-002** | Cam Chain Outer | No drawing yet. |
| `cam_shaft_bushing_mced.SLDPRT` | `frame\17_Cam Chain Parts` | BSH (Part) | **MC-BSH-002** | Cam Shaft Bushing | No drawing yet. |
| `cam_shaft_mced.SLDPRT` | `frame\17_Cam Chain Parts` | SFT (Part) | **MC-SFT-006** | Cam Shaft | No drawing yet. |
| `cam_shaft_sprocket_mced.SLDPRT` | `frame\17_Cam Chain Parts` | SPK (Part) | **MC-SPK-003** | Cam Shaft Sprocket | No drawing yet. |
| `articulated_rod_lower_mced.SLDPRT` | `frame\18_Articulated Rod Upper and Lower` | ROD (Part) | **MC-ROD-002** | Articulated Rod Lower | No drawing yet. |
| `articulated_rod_upper_mced.SLDPRT` | `frame\18_Articulated Rod Upper and Lower` | ROD (Part) | **MC-ROD-001** | Articulated Rod Upper | No drawing yet. |
| `20mm_bearing.SLDASM` | `frame\19_20mm and 30mm Ball Bearings` | ASM (Assembly) | **MC-ASM-012** | 20mm Bearing | No drawing yet. |
| `20mm_bearing_balls_mced.SLDPRT` | `frame\19_20mm and 30mm Ball Bearings` | BRG (Part) | **MC-BRG-007** | 20mm Bearing Balls | No drawing yet. |
| `20mm_bearing_inner_ring_mced.SLDPRT` | `frame\19_20mm and 30mm Ball Bearings` | BRG (Part) | **MC-BRG-005** | 20mm Bearing Inner Ring | No drawing yet. |
| `20mm_bearing_outer_ring_mced.SLDPRT` | `frame\19_20mm and 30mm Ball Bearings` | BRG (Part) | **MC-BRG-002** | 20mm Bearing Outer Ring | No drawing yet. |
| `30mm_bearing.SLDASM` | `frame\19_20mm and 30mm Ball Bearings` | ASM (Assembly) | **MC-ASM-017** | 30mm Bearing | No drawing yet. |
| `30mm_bearing_balls_mced.SLDPRT` | `frame\19_20mm and 30mm Ball Bearings` | BRG (Part) | **MC-BRG-003** | 30mm Bearing Balls | No drawing yet. |
| `30mm_bearing_inner_ring_mced.SLDPRT` | `frame\19_20mm and 30mm Ball Bearings` | BRG (Part) | **MC-BRG-004** | 30mm Bearing Inner Ring | No drawing yet. |
| `30mm_bearing_outer_ring_mced.SLDPRT` | `frame\19_20mm and 30mm Ball Bearings` | BRG (Part) | **MC-BRG-006** | 30mm Bearing Outer Ring | No drawing yet. |
| `bolt_cylinder_section_mced.SLDPRT` | `frame\20_Bolts - Various` | BLT (Part) | **MC-BLT-010** | Bolt Cylinder Section | No drawing yet. |
| `bolt_engine_case_l_to_c_mced.SLDPRT` | `frame\20_Bolts - Various` | BLT (Part) | **MC-BLT-009** | Bolt Engine Case L To C | No drawing yet. |
| `bolt_engine_case_l_to_r_mced.SLDPRT` | `frame\20_Bolts - Various` | BLT (Part) | **MC-BLT-008** | Bolt Engine Case L To R | No drawing yet. |
| `bolt_front_wheel_frame_clamp_mced.SLDPRT` | `frame\20_Bolts - Various` | BLT (Part) | **MC-BLT-007** | Bolt Front Wheel Frame Clamp | No drawing yet. |
| `bolt_head_case_mced.SLDPRT` | `frame\20_Bolts - Various` | BLT (Part) | **MC-BLT-006** | Bolt Head Case | No drawing yet. |
| `bolt_large_engine_case_l_to_r_mced.SLDPRT` | `frame\20_Bolts - Various` | BLT (Part) | **MC-BLT-005** | Bolt Large Engine Case L To R | No drawing yet. |
| `frame_engine_bolt.SLDPRT` | `frame\20_Bolts - Various` | BLT (Part) | **MC-BLT-004** | Frame Engine Bolt | No drawing yet. |
| `testscrew.SLDPRT` | `frame\20_Bolts - Various` | BLT (Part) | **MC-BLT-003** | Test Screw | **FLAG** - looks like a throwaway test file. Confirm it belongs in the release set. No drawing yet. |
| `wheel_rim.SLDPRT` | `frame\21_Wheel Rim` | RIM (Part) | **MC-RIM-001** | Wheel Rim | No drawing yet. |
| `tyre.SLDPRT` | `frame\22_Tyre` | TYR (Part) | **MC-TYR-001** | Tyre | No drawing yet. |
| `rear_wheel_brake_plate.SLDPRT` | `frame\23_Rear Wheel Parts` | PLT (Part) | **MC-PLT-004** | Rear Wheel Brake Plate | No drawing yet. |
| `rear_wheel_frame.SLDPRT` | `frame\23_Rear Wheel Parts` | FRM (Part) | **MC-FRM-002** | Rear Wheel Frame | No drawing yet. |
| `rear_wheel_frame_18mm.SLDPRT` | `frame\23_Rear Wheel Parts` | FRM (Part) | **MC-FRM-007** | Rear Wheel Frame 18mm | **FLAG** - size variant of `rear_wheel_frame`; may be an alternate config rather than a distinct drawing. No drawing yet. |
| `rear_wheel_frame_absorber_shaft.SLDPRT` | `frame\23_Rear Wheel Parts` | SFT (Part) | **MC-SFT-009** | Rear Wheel Frame Absorber Shaft | No drawing yet. |
| `rear_wheel_frame_as_bolt.SLDPRT` | `frame\23_Rear Wheel Parts` | BLT (Part) | **MC-BLT-013** | Rear Wheel Frame As Bolt | **FLAG** - `as` is unclear (absorber shaft?). Title is a guess. No drawing yet. |
| `rear_wheel_frame_c_shaft_plug.SLDPRT` | `frame\23_Rear Wheel Parts` | PLG (Part) | **MC-PLG-003** | Rear Wheel Frame C Shaft Plug | No drawing yet. |
| `rear_wheel_frame_connector_shaf.SLDPRT` | `frame\23_Rear Wheel Parts` | SFT (Part) | **MC-SFT-008** | Rear Wheel Frame Connector Shaf | **FLAG** - filename appears truncated (`shaf` -> `shaft`). Do NOT rename; noted only. No drawing yet. |
| `rear_wheel_frame_end_cap.SLDPRT` | `frame\23_Rear Wheel Parts` | CAP (Part) | **MC-CAP-001** | Rear Wheel Frame End Cap | No drawing yet. |
| `rear_wheel_frame_old.SLDPRT` | `frame\23_Rear Wheel Parts` | FRM (Part) | **MC-FRM-006** | Rear Wheel Frame Old | **FLAG** - `_old` suggests superseded by `rear_wheel_frame`. Confirm before numbering. No drawing yet. |
| `rear_wheel_frame_shaft.SLDPRT` | `frame\23_Rear Wheel Parts` | SFT (Part) | **MC-SFT-007** | Rear Wheel Frame Shaft | No drawing yet. |
| `rear_wheel_frame_shaft_bolt.SLDPRT` | `frame\23_Rear Wheel Parts` | BLT (Part) | **MC-BLT-012** | Rear Wheel Frame Shaft Bolt | No drawing yet. |
| `rear_wheel_sprocket.SLDPRT` | `frame\23_Rear Wheel Parts` | SPK (Part) | **MC-SPK-004** | Rear Wheel Sprocket | No drawing yet. |
| `rear_wheel_sprocket_bolt.SLDPRT` | `frame\23_Rear Wheel Parts` | BLT (Part) | **MC-BLT-011** | Rear Wheel Sprocket Bolt | No drawing yet. |
| `front_wheel_brake_plate.SLDPRT` | `frame\24_Front Wheel Parts` | PLT (Part) | **MC-PLT-006** | Front Wheel Brake Plate | No drawing yet. |
| `front_wheel_brake_plate_left.SLDPRT` | `frame\24_Front Wheel Parts` | PLT (Part) | **MC-PLT-005** | Front Wheel Brake Plate Left | No drawing yet. |
| `front_wheel_frame_shaft_bolt.SLDPRT` | `frame\24_Front Wheel Parts` | BLT (Part) | **MC-BLT-015** | Front Wheel Frame Shaft Bolt | No drawing yet. |
| `front_wheel_frame_shaft_boltdd.SLDPRT` | `frame\24_Front Wheel Parts` | BLT (Part) | **MC-BLT-016** | Front Wheel Frame Shaft Bolt (dd) | **FLAG** - `dd` suffix suggests a stray duplicate of `front_wheel_frame_shaft_bolt`. No drawing yet. |
| `front_wheel_guard.SLDPRT` | `frame\24_Front Wheel Parts` | GRD (Part) | **MC-GRD-001** | Front Wheel Guard | No drawing yet. |
| `front_wheel_guard_bridge.SLDPRT` | `frame\24_Front Wheel Parts` | BDG (Part) | **MC-BDG-001** | Front Wheel Guard Bridge | No drawing yet. |
| `front_wheel_guard_bridge_pin_a.SLDPRT` | `frame\24_Front Wheel Parts` | PIN (Part) | **MC-PIN-005** | Front Wheel Guard Bridge Pin A | No drawing yet. |
| `front_wheel_guard_bridge_pin_b.SLDPRT` | `frame\24_Front Wheel Parts` | PIN (Part) | **MC-PIN-004** | Front Wheel Guard Bridge Pin B | No drawing yet. |
| `front_wheel_lower_connector_arm.SLDPRT` | `frame\24_Front Wheel Parts` | ARM (Part) | **MC-ARM-007** | Front Wheel Lower Connector Arm | No drawing yet. |
| `front_wheel_m_frame_inner_pipe.SLDPRT` | `frame\24_Front Wheel Parts` | PIP (Part) | **MC-PIP-002** | Front Wheel M Frame Inner Pipe | No drawing yet. |
| `front_wheel_shaft.SLDPRT` | `frame\24_Front Wheel Parts` | SFT (Part) | **MC-SFT-010** | Front Wheel Shaft | No drawing yet. |
| `front_wheel_side_base_pipe.SLDPRT` | `frame\24_Front Wheel Parts` | PIP (Part) | **MC-PIP-003** | Front Wheel Side Base Pipe | No drawing yet. |
| `front_wheel_side_pipe.SLDPRT` | `frame\24_Front Wheel Parts` | PIP (Part) | **MC-PIP-001** | Front Wheel Side Pipe | No drawing yet. |
| `front_wheel_side_pipe_top_bolt.SLDPRT` | `frame\24_Front Wheel Parts` | BLT (Part) | **MC-BLT-014** | Front Wheel Side Pipe Top Bolt | No drawing yet. |
| `front_wheel_upper_connector_arm.SLDPRT` | `frame\24_Front Wheel Parts` | ARM (Part) | **MC-ARM-006** | Front Wheel Upper Connector Arm | No drawing yet. |
| `front_wheel_brake_body.SLDPRT` | `frame\25_Front Wheel Brake Body and Mirror` | BDY (Part) | **MC-BDY-001** | Front Wheel Brake Body | No drawing yet. |
| `front_wheel_brake_body_mirror.SLDPRT` | `frame\25_Front Wheel Brake Body and Mirror` | MIR (Part) | **MC-MIR-001** | Front Wheel Brake Body Mirror | No drawing yet. |
| `foot_rest.SLDPRT` | `frame\26_Foot Rest Parts` | RST (Part) | **MC-RST-001** | Foot Rest | No drawing yet. |
| `foot_rest_kick_guard.SLDPRT` | `frame\26_Foot Rest Parts` | GRD (Part) | **MC-GRD-003** | Foot Rest Kick Guard | No drawing yet. |
| `foot_rest_pin.SLDPRT` | `frame\26_Foot Rest Parts` | PIN (Part) | **MC-PIN-012** | Foot Rest Pin | No drawing yet. |
| `rear_foot_rest_frame.SLDPRT` | `frame\26_Foot Rest Parts` | FRM (Part) | **MC-FRM-003** | Rear Foot Rest Frame | No drawing yet. |
| `exhaust_muffler_guard.SLDPRT` | `frame\27_Exhaust Parts` | GRD (Part) | **MC-GRD-002** | Exhaust Muffler Guard | No drawing yet. |
| `exhaust_muffler_mid_section.SLDPRT` | `frame\27_Exhaust Parts` | MUF (Part) | **MC-MUF-001** | Exhaust Muffler Mid Section | No drawing yet. |
| `exhaust_muffler_upper_section.SLDPRT` | `frame\27_Exhaust Parts` | MUF (Part) | **MC-MUF-002** | Exhaust Muffler Upper Section | No drawing yet. |
| `air_intake_grill_body_mced.SLDPRT` | `frame\29_Air Intake Front Grill Body and Cap` | BDY (Part) | **MC-BDY-004** | Air Intake Grill Body | No drawing yet. |
| `air_intake_grill_cap_mced.SLDPRT` | `frame\29_Air Intake Front Grill Body and Cap` | CAP (Part) | **MC-CAP-002** | Air Intake Grill Cap | No drawing yet. |
| `shock_absorber_arm_pin_a.SLDPRT` | `frame\30_Shock Absorber Parts` | PIN (Part) | **MC-PIN-010** | Shock Absorber Arm Pin A | No drawing yet. |
| `shock_absorber_arm_pin_b.SLDPRT` | `frame\30_Shock Absorber Parts` | PIN (Part) | **MC-PIN-007** | Shock Absorber Arm Pin B | No drawing yet. |
| `shock_absorber_arm_pin_c.SLDPRT` | `frame\30_Shock Absorber Parts` | PIN (Part) | **MC-PIN-008** | Shock Absorber Arm Pin C | No drawing yet. |
| `shock_absorber_arm_pin_d.SLDPRT` | `frame\30_Shock Absorber Parts` | PIN (Part) | **MC-PIN-009** | Shock Absorber Arm Pin D | No drawing yet. |
| `shock_absorber_bushing.SLDPRT` | `frame\30_Shock Absorber Parts` | BSH (Part) | **MC-BSH-003** | Shock Absorber Bushing | No drawing yet. |
| `shock_absorber_connector_arm.SLDPRT` | `frame\30_Shock Absorber Parts` | ARM (Part) | **MC-ARM-010** | Shock Absorber Connector Arm | No drawing yet. |
| `shock_absorber_frame_arm.SLDPRT` | `frame\30_Shock Absorber Parts` | ARM (Part) | **MC-ARM-009** | Shock Absorber Frame Arm | No drawing yet. |
| `shock_absorber_inner_section.SLDPRT` | `frame\30_Shock Absorber Parts` | SHK (Part) | **MC-SHK-002** | Shock Absorber Inner Section | No drawing yet. |
| `shock_absorber_outer_section.SLDPRT` | `frame\30_Shock Absorber Parts` | SHK (Part) | **MC-SHK-001** | Shock Absorber Outer Section | No drawing yet. |
| `shock_absorber_pin_a_bolt.SLDPRT` | `frame\30_Shock Absorber Parts` | BLT (Part) | **MC-BLT-017** | Shock Absorber Pin A Bolt | No drawing yet. |
| `shock_absorber_spring.SLDPRT` | `frame\30_Shock Absorber Parts` | SPR (Part) | **MC-SPR-002** | Shock Absorber Spring | No drawing yet. |
| `hand_brake_body.SLDPRT` | `frame\31_Handlebar and Hand Brake Parts` | BDY (Part) | **MC-BDY-002** | Hand Brake Body | No drawing yet. |
| `hand_brake_cable_connector.SLDPRT` | `frame\31_Handlebar and Hand Brake Parts` | CON (Part) | **MC-CON-001** | Hand Brake Cable Connector | No drawing yet. |
| `hand_brake_handlebar_bridge.SLDPRT` | `frame\31_Handlebar and Hand Brake Parts` | BDG (Part) | **MC-BDG-003** | Hand Brake Handlebar Bridge | No drawing yet. |
| `hand_brake_lever.SLDPRT` | `frame\31_Handlebar and Hand Brake Parts` | LVR (Part) | **MC-LVR-001** | Hand Brake Lever | No drawing yet. |
| `hand_brake_pin.SLDPRT` | `frame\31_Handlebar and Hand Brake Parts` | PIN (Part) | **MC-PIN-006** | Hand Brake Pin | No drawing yet. |
| `handle_bar.SLDPRT` | `frame\31_Handlebar and Hand Brake Parts` | BAR (Part) | **MC-BAR-001** | Handlebar | No drawing yet. |
| `handle_bar_connector_arm_bridge.SLDPRT` | `frame\31_Handlebar and Hand Brake Parts` | BDG (Part) | **MC-BDG-002** | Handle Bar Connector Arm Bridge | No drawing yet. |
| `handle_bar_connector_bridge_pin.SLDPRT` | `frame\31_Handlebar and Hand Brake Parts` | PIN (Part) | **MC-PIN-011** | Handle Bar Connector Bridge Pin | No drawing yet. |
| `handle_bar_grip.SLDPRT` | `frame\31_Handlebar and Hand Brake Parts` | GRP (Part) | **MC-GRP-001** | Handle Bar Grip | No drawing yet. |
| `headlight_back_case.SLDPRT` | `frame\32_Headlight Parts` | CSE (Part) | **MC-CSE-010** | Headlight Back Case | No drawing yet. |
| `headlight_bulb.SLDPRT` | `frame\32_Headlight Parts` | BLB (Part) | **MC-BLB-003** | Headlight Bulb | No drawing yet. |
| `headlight_bulb_reflective_liner.SLDPRT` | `frame\32_Headlight Parts` | LNR (Part) | **MC-LNR-001** | Headlight Bulb Reflective Liner | No drawing yet. |
| `headlight_connector_arm.SLDPRT` | `frame\32_Headlight Parts` | ARM (Part) | **MC-ARM-008** | Headlight Connector Arm | No drawing yet. |
| `headlight_front_case.SLDPRT` | `frame\32_Headlight Parts` | CSE (Part) | **MC-CSE-009** | Headlight Front Case | No drawing yet. |
| `headlight_lightbulb.SLDPRT` | `frame\32_Headlight Parts` | BLB (Part) | **MC-BLB-002** | Headlight Lightbulb | No drawing yet. |
| `headlight_lightbulb_back.SLDPRT` | `frame\32_Headlight Parts` | BLB (Part) | **MC-BLB-001** | Headlight Lightbulb Back | No drawing yet. |
| `light-frame-pin.SLDPRT` | `frame\33-Light Frame Pin` | PIN (Part) | **MC-PIN-013** | Light Frame Pin | No drawing yet. |
| `rear-light-case-bulb.SLDPRT` | `frame\34 - Rear Light Parts` | BLB (Part) | **MC-BLB-005** | Rear Light Case Bulb | No drawing yet. |
| `rear-light-frame.SLDPRT` | `frame\34 - Rear Light Parts` | FRM (Part) | **MC-FRM-005** | Rear Light Frame | No drawing yet. |
| `rear-light-front-case.SLDPRT` | `frame\34 - Rear Light Parts` | CSE (Part) | **MC-CSE-012** | Rear Light Front Case | No drawing yet. |
| `rear-light-inner-bulb.SLDPRT` | `frame\34 - Rear Light Parts` | BLB (Part) | **MC-BLB-004** | Rear Light Inner Bulb | No drawing yet. |
| `rear-light-upper-frame.SLDPRT` | `frame\34 - Rear Light Parts` | FRM (Part) | **MC-FRM-004** | Rear Light Upper Frame | No drawing yet. |
| `rear-lightbulb-base.SLDPRT` | `frame\34 - Rear Light Parts` | BAS (Part) | **MC-BAS-001** | Rear Lightbulb Base | No drawing yet. |
| `speedometer-body.SLDPRT` | `frame\35-Speedometer` | BDY (Part) | **MC-BDY-003** | Speedometer Body | No drawing yet. |
| `speedometer-screen.SLDPRT` | `frame\35-Speedometer` | SCR (Part) | **MC-SCR-001** | Speedometer Screen | No drawing yet. |
| `wing-mirror-arm.SLDPRT` | `frame\36- Wing mirror parts` | ARM (Part) | **MC-ARM-011** | Wing Mirror Arm | No drawing yet. |
| `wing-mirror-case.SLDPRT` | `frame\36- Wing mirror parts` | CSE (Part) | **MC-CSE-011** | Wing Mirror Case | No drawing yet. |
| `wing-mirror-connector.SLDPRT` | `frame\36- Wing mirror parts` | CON (Part) | **MC-CON-002** | Wing Mirror Connector | No drawing yet. |
| `assemblyenginecase.SLDASM` | `frame\43_Engine Assembly` | ASM (Assembly) | **MC-ASM-001** | Assemblyenginecase | **FLAG** - near-duplicate of `assemblyenginecaseuse`. Confirm which is current. No drawing yet. |
| `assemblyenginecaseuse.SLDASM` | `frame\43_Engine Assembly` | ASM (Assembly) | **MC-ASM-002** | Assemblyenginecaseuse | **FLAG** - near-duplicate of `assemblyenginecase`. Confirm which is current. No drawing yet. |
| `lswugpart2.SLDPRT` | `frame\99_Unsorted - Review` | UNK (Part) | **MC-UNK-002** | Unidentified Part 2 | **AMBIGUOUS** - generic name, no type inferable. Needs your input. No drawing yet. |
| `part.SLDPRT` | `frame\99_Unsorted - Review` | UNK (Part) | **MC-UNK-001** | Unidentified Part | **AMBIGUOUS** - generic name, no type inferable. Needs your input. No drawing yet. |
| `airintake_mandifold.SLDPRT` | `frame\Assembly` | MAN (Part) | **MC-MAN-001** | Air Intake Manifold | **FLAG** - filename misspells 'manifold'. Do NOT rename; title corrected here only. No drawing yet. |
| `Assem3.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-010** | Assem3 | **AMBIGUOUS** - default SolidWorks name, contents unknown. Needs your input. No drawing yet. |
| `camchainassembly_ed.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-007** | Camchainassembly Ed | **FLAG** - one of three cam chain assemblies. Confirm which is current. No drawing yet. |
| `camchainassembly_ed2.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-008** | Camchainassembly Ed2 | **FLAG** - one of three cam chain assemblies. Confirm which is current. No drawing yet. |
| `camchains_assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-006** | Camchains Assembly | **FLAG** - one of three cam chain assemblies. Confirm which is current. No drawing yet. |
| `clutchhub-assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-003** | Clutchhub Assembly | **FLAG** - near-duplicate of `clutchhubassembly`. Confirm which is current. No drawing yet. |
| `clutchhubassembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-009** | Clutchhubassembly | **FLAG** - near-duplicate of `clutchhub-assembly`. Confirm which is current. No drawing yet. |
| `crankshaft_assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-005** | Crankshaft Assembly | No drawing yet. |
| `engine_assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-014** | Engine Assembly | No drawing yet. |
| `enginegearsassembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-011** | Enginegearsassembly | No drawing yet. |
| `enginehead_assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-013** | Enginehead Assembly | No drawing yet. |
| `headlight_assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-021** | Headlight Assembly | No drawing yet. |
| `piston assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-004** | Piston Assembly | No drawing yet. |
| `rear foot rest front and mirror assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-019** | Rear Foot Rest Front And Mirror Assembly | No drawing yet. |
| `rear foot rest front assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-020** | Rear Foot Rest Front Assembly | No drawing yet. |
| `rearwheel_assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-016** | Rearwheel Assembly | No drawing yet. |
| `rearwheel_frame_aseembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-018** | Rearwheel Frame Aseembly | No drawing yet. |
| `shockabsorber_assembly.SLDASM` | `frame\Assembly` | ASM (Assembly) | **MC-ASM-015** | Shockabsorber Assembly | No drawing yet. |
| `chain_guard.SLDPRT` | `frame\Chain` | GRD (Part) | **MC-GRD-004** | Chain Guard | No drawing yet. |
| `chain_inner.SLDPRT` | `frame\Chain` | CHN (Part) | **MC-CHN-003** | Chain Inner | No drawing yet. |
| `chain_outer.SLDPRT` | `frame\Chain` | CHN (Part) | **MC-CHN-004** | Chain Outer | No drawing yet. |

## Items needing your decision

- `airintake_mandifold.SLDPRT` (frame\Assembly) - **FLAG** - filename misspells 'manifold'. Do NOT rename; title corrected here only.
- `Assem3.SLDASM` (frame\Assembly) - **AMBIGUOUS** - default SolidWorks name, contents unknown. Needs your input.
- `assemblyenginecase.SLDASM` (frame\43_Engine Assembly) - **FLAG** - near-duplicate of `assemblyenginecaseuse`. Confirm which is current.
- `assemblyenginecaseuse.SLDASM` (frame\43_Engine Assembly) - **FLAG** - near-duplicate of `assemblyenginecase`. Confirm which is current.
- `camchainassembly_ed.SLDASM` (frame\Assembly) - **FLAG** - one of three cam chain assemblies. Confirm which is current.
- `camchainassembly_ed2.SLDASM` (frame\Assembly) - **FLAG** - one of three cam chain assemblies. Confirm which is current.
- `camchains_assembly.SLDASM` (frame\Assembly) - **FLAG** - one of three cam chain assemblies. Confirm which is current.
- `clutch_hub_gear_bearing.SLDPRT` (frame\04_Clutch Hub Parts) - Typed by noun head (`bearing`), not the `gear` in the name.
- `clutch_hub_gear_pin.SLDPRT` (frame\04_Clutch Hub Parts) - Typed by noun head (`pin`), not the `gear` in the name.
- `clutch_hub_gear_plate.SLDPRT` (frame\04_Clutch Hub Parts) - Typed by noun head (`plate`), not the `gear` in the name.
- `clutchhub-assembly.SLDASM` (frame\Assembly) - **FLAG** - near-duplicate of `clutchhubassembly`. Confirm which is current.
- `clutchhubassembly.SLDASM` (frame\Assembly) - **FLAG** - near-duplicate of `clutchhub-assembly`. Confirm which is current.
- `front_wheel_frame_shaft_boltdd.SLDPRT` (frame\24_Front Wheel Parts) - **FLAG** - `dd` suffix suggests a stray duplicate of `front_wheel_frame_shaft_bolt`.
- `lswugpart2.SLDPRT` (frame\99_Unsorted - Review) - **AMBIGUOUS** - generic name, no type inferable. Needs your input.
- `part.SLDPRT` (frame\99_Unsorted - Review) - **AMBIGUOUS** - generic name, no type inferable. Needs your input.
- `piston_bushing_Eng_Drw.SLDPRT` (frame\16_Piston Parts) - **FLAG** - `Eng_Drw` suffix is unusual; confirm it is the production part.
- `rear_wheel_frame_18mm.SLDPRT` (frame\23_Rear Wheel Parts) - **FLAG** - size variant of `rear_wheel_frame`; may be an alternate config rather than a distinct drawing.
- `rear_wheel_frame_as_bolt.SLDPRT` (frame\23_Rear Wheel Parts) - **FLAG** - `as` is unclear (absorber shaft?). Title is a guess.
- `rear_wheel_frame_connector_shaf.SLDPRT` (frame\23_Rear Wheel Parts) - **FLAG** - filename appears truncated (`shaf` -> `shaft`). Do NOT rename; noted only.
- `rear_wheel_frame_old.SLDPRT` (frame\23_Rear Wheel Parts) - **FLAG** - `_old` suggests superseded by `rear_wheel_frame`. Confirm before numbering.
- `testscrew.SLDPRT` (frame\20_Bolts - Various) - **FLAG** - looks like a throwaway test file. Confirm it belongs in the release set.

## Sequencing

Sequence order uses **filesystem creation date**, which for this project is when each file landed in `Downloads` - not necessarily when you designed the part. Dates run 2026-04-22 to 2026-09-03 and track the folder order closely, so the result is sensible, but if you want strict alphabetical or strict folder order instead, say so and I will renumber.


## Open issues

1. **Only 3 of 192 documents are drawings.** The macro in Step 4 can only write properties to a `.SLDDRW` that exists. See the note in chat about writing the properties to the models instead so drawings inherit them.

2. **Lock files present** - these were excluded from the index, but they mean the documents are open in SolidWorks now or were left behind by a crash. Close them before running any macro:

   - `frame\04_Clutch Hub Parts\~$clutch_hub_basket_mced.SLDDRW`
   - `frame\04_Clutch Hub Parts\~$clutch_hub_basket_mced.SLDPRT`
