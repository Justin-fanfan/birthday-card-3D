/*
 * Birthday GuanDan rack - continuous stepped edition
 * OpenSCAD 2021.01 compatible.
 *
 * part = "assembly" | "rack" | "heartA" | "heartA_preview" | "heartA_base" |
 *        "heartA_red" | "heartA_black" | "sliderA" | "sliderB" |
 *        "slot_test" | "slider_test"
 */

include <qr_data.scad>

$fn = 48;

part = "assembly";
show_score_labels = true;
show_qr = true;

// ---------- continuous rack ----------
rack_w = 210;
rack_d = 84;
base_t = 5;
corner_r = 4;
edge_bevel = 0.9;

front_d = 25;
front_h = 33;

// Overlapping rounded masses form one continuous, gap-free stepped body.
tier1_y = 17; tier1_d = 31; tier1_h = 37; row1_y = 34;
tier2_y = 39; tier2_d = 31; tier2_h = 45; row2_y = 56;
tier3_y = 61; tier3_d = 23; tier3_h = 53; row3_y = 77;

card_slot_len = 192;
card_slot_w = 2.4;
card_slot_depth = 10;
card_lean = 12;

display_slot_len = 54;
display_slot_w = 5.4;
display_slot_depth = 11;
display_lean = 8;
display_y = 12;

// ---------- simple captive score sliders ----------
score_track_len = 64;
score_track_z = 15.5;
score_left_x = 5;
score_right_x = rack_w - score_left_x - score_track_len;
score_load_offset = 4.2;
score_first_offset = 11;
score_last_offset = 60;
// The neck is 3.0 mm wide. A 2.85 mm connecting channel gives a mild
// interference fit, while the larger pockets at each score release it.
score_open_h = 2.85;
score_detent_d = 3.5;
score_cavity_h = 6.6;
score_load_d = 7.4;
score_open_depth = 2.8;
score_cavity_y = 1.8;
score_cavity_depth = 4.2;
score_label_size = 4.5;
score_text_size = 4.2;
score_engrave_depth = 0.55;
score_preview_inlay_t = 0.08;

slider_flange_d = 6.0;
slider_flange_t = 1.5;
slider_neck_d = 3.0;
slider_neck_h = 2.8;
slider_knob_d = 8.2;
slider_knob_h = 2.3;
slider_assembly_y = score_cavity_y + score_cavity_depth - 1.1;

levels = ["2","3","4","5","6","7","8","9","10","J","Q","K","A"];

// ---------- heart A ----------
card_w = 52;
card_h = 78;
card_t = 4.0;
card_r = 4.5;
card_bevel = 0.65;
relief_h = 0.9;
border_w = 1.2;
qr_size = 34;
qr_module_growth = 0.10;
font_main = "Microsoft YaHei:style=Bold";
font_latin = "Arial:style=Bold";

// ------------------------------------------------------------
// Shared 2D/3D helpers
// ------------------------------------------------------------
module rounded_rect_2d(w,d,r) {
    hull() {
        translate([r,r]) circle(r=r);
        translate([w-r,r]) circle(r=r);
        translate([r,d-r]) circle(r=r);
        translate([w-r,d-r]) circle(r=r);
    }
}

module soft_prism(w,d,h,r=3,b=0.8) {
    hull() {
        translate([b,b,0]) linear_extrude(height=0.05)
            rounded_rect_2d(w-2*b,d-2*b,max(0.5,r-b));
        translate([0,0,b]) linear_extrude(height=0.05)
            rounded_rect_2d(w,d,r);
        translate([0,0,h-b]) linear_extrude(height=0.05)
            rounded_rect_2d(w,d,r);
        translate([b,b,h-0.05]) linear_extrude(height=0.05)
            rounded_rect_2d(w-2*b,d-2*b,max(0.5,r-b));
    }
}

// Extrude a YZ side profile along world X.
module extrude_side_profile(width) {
    multmatrix([
        [0,0,1,0],
        [1,0,0,0],
        [0,1,0,0],
        [0,0,0,1]
    ]) linear_extrude(height=width) children();
}

// ------------------------------------------------------------
// Gap-free, continuous rack body
// ------------------------------------------------------------
module rack_side_profile_2d() {
    union() {
        // A full base closes the shallow rounding at every step.
        rounded_rect_2d(rack_d,base_t,1.8);
        rounded_rect_2d(front_d,front_h,4.2);
        translate([tier1_y,0]) rounded_rect_2d(tier1_d,tier1_h,4.2);
        translate([tier2_y,0]) rounded_rect_2d(tier2_d,tier2_h,4.2);
        translate([tier3_y,0]) rounded_rect_2d(tier3_d,tier3_h,4.2);
    }
}

module rack_solid() {
    // The envelope rounds the left/right footprint while the YZ profile
    // provides the flowing, fully filled stepped silhouette.
    intersection() {
        extrude_side_profile(rack_w) rack_side_profile_2d();
        soft_prism(rack_w,rack_d,tier3_h+2,corner_r,edge_bevel);
    }
}

module slot_cutter(y,z_top,len,width,depth,lean) {
    translate([rack_w/2,y,z_top-depth/2+1])
        rotate([-lean,0,0])
            cube([len,width,depth+8],center=true);
}

module card_slot_cutters() {
    slot_cutter(row1_y,tier1_h,card_slot_len,card_slot_w,card_slot_depth,card_lean);
    slot_cutter(row2_y,tier2_h,card_slot_len,card_slot_w,card_slot_depth,card_lean);
    slot_cutter(row3_y,tier3_h,card_slot_len,card_slot_w,card_slot_depth,card_lean);
}

module display_slot_cutter() {
    slot_cutter(display_y,front_h,display_slot_len,display_slot_w,display_slot_depth,display_lean);
}

module y_cylinder(x,y,z,d,depth) {
    translate([x,y+depth,z])
        rotate([90,0,0]) cylinder(h=depth,d=d);
}

module horizontal_pill(x0,len,y,z,d,depth) {
    hull() {
        y_cylinder(x0+d/2,y,z,d,depth);
        y_cylinder(x0+len-d/2,y,z,d,depth);
    }
}

module score_track_cutter(
    x0,
    len=score_track_len,
    z=score_track_z,
    detent_first=score_first_offset,
    detent_last=score_last_offset,
    detent_count=13
) {
    // Narrow visible opening plus a wider hidden cavity retains the slider.
    horizontal_pill(x0,len,-0.2,z,score_open_h,score_open_depth+0.2);
    horizontal_pill(x0,len,score_cavity_y,z,score_cavity_h,score_cavity_depth);

    // Round pockets line up with the printed score ticks. The 3.0 mm slider
    // neck clicks through the slightly narrower connecting channel and rests
    // freely in each pocket. This is rotation-independent and FDM-friendly.
    for (i=[0:detent_count-1])
        let(detent_x = x0 + detent_first
            + i*(detent_last-detent_first)/(detent_count-1))
            y_cylinder(detent_x,-0.2,z,score_detent_d,
                score_open_depth+0.2);

    // The rear flange enters through this port, then moves into the track.
    y_cylinder(x0+score_load_offset,-0.2,z,score_load_d,
        score_cavity_y+score_cavity_depth+0.4);
}

module score_track_cutters() {
    score_track_cutter(score_left_x);
    score_track_cutter(score_right_x);
}

module rack_base_geometry() {
    difference() {
        rack_solid();
        card_slot_cutters();
        display_slot_cutter();
        score_track_cutters();
        score_face_details();
    }
}

// ------------------------------------------------------------
// Front-face score graphics: engraved for robust FDM printing and easy paint.
// ------------------------------------------------------------
module face_text(str,x,z,size=4.5,font=font_main,preview=false) {
    start_y = preview ? score_engrave_depth+0.02
        : score_engrave_depth+0.1;
    extrusion = preview ? score_preview_inlay_t
        : score_engrave_depth+0.3;
    translate([x,start_y,z])
        rotate([90,0,0])
            linear_extrude(height=extrusion)
                text(str,size=size,font=font,halign="center",valign="center");
}

module face_tick(x,z,h=1.7,w=0.55,preview=false) {
    start_y = preview ? score_engrave_depth+0.02
        : score_engrave_depth+0.1;
    extrusion = preview ? score_preview_inlay_t
        : score_engrave_depth+0.3;
    translate([x,start_y,z])
        rotate([90,0,0])
            linear_extrude(height=extrusion)
                square([w,h],center=true);
}

function score_x(x0,i) =
    x0 + score_first_offset + i*(score_last_offset-score_first_offset)/12;

module score_scale(x0,label,preview=false) {
    face_text(label,x0+score_track_len/2,26.7,score_label_size,
        preview=preview);
    for (i=[0:12])
        face_tick(score_x(x0,i),9.6,(i==0 || i==12) ? 2.2 : 1.5,
            preview=preview);
    face_text("2",score_x(x0,0),6.6,score_text_size,
        preview=preview);
    face_text("A",score_x(x0,12),6.6,score_text_size,font=font_latin,
        preview=preview);
}

module score_face_details() {
    if (show_score_labels) {
        score_scale(score_left_x,"A组");
        score_scale(score_right_x,"B组");
    }
}

module rack() {
    rack_base_geometry();
}

// ------------------------------------------------------------
// Captive slider: print flat on its rear flange, no support.
// ------------------------------------------------------------
module slider() {
    union() {
        cylinder(h=slider_flange_t,d=slider_flange_d);
        translate([0,0,slider_flange_t-0.1])
            cylinder(h=slider_neck_h+0.2,d=slider_neck_d);
        hull() {
            translate([0,0,slider_flange_t+slider_neck_h-0.05])
                cylinder(h=0.1,d=slider_knob_d-0.8);
            translate([0,0,slider_flange_t+slider_neck_h+slider_knob_h-0.1])
                cylinder(h=0.1,d=slider_knob_d);
        }
    }
}

module slider_standing_colored(x,z,color_value) {
    translate([x,slider_assembly_y,z]) rotate([90,0,0])
        color(color_value) slider();
}

// ------------------------------------------------------------
// Heart A card
// ------------------------------------------------------------
function heart_curve_point(a) = [
    0.42 * 16 * sin(a) * sin(a) * sin(a),
    0.42 * (13*cos(a) - 5*cos(2*a) - 2*cos(3*a) - cos(4*a))
];

module heart_2d(s=1) {
    // One continuous curve avoids the visible circle/triangle seam.
    scale([s,s])
        polygon(points=[for (i=[0:95]) heart_curve_point(i*360/96)]);
}

module card_base() {
    // A thicker body with a light all-round bevel gives the card more weight.
    soft_prism(card_w,card_h,card_t,card_r,card_bevel);
}

module card_red_relief() {
    z = card_t - 0.05;
    translate([0,0,z]) linear_extrude(height=relief_h)
        difference() {
            translate([2.0,2.0]) rounded_rect_2d(card_w-4.0,card_h-4.0,3.1);
            translate([2.0+border_w,2.0+border_w])
                rounded_rect_2d(card_w-4.0-2*border_w,card_h-4.0-2*border_w,2.2);
        }
    translate([7.0,card_h-8.5,z]) linear_extrude(height=relief_h)
        text("A",size=8.5,font=font_latin,halign="center",valign="center");
    translate([7.0,card_h-15.2,z]) linear_extrude(height=relief_h) heart_2d(0.52);
    translate([card_w/2,57,z]) linear_extrude(height=relief_h) heart_2d(1.05);
}

module qr_2d(target_size=30) {
    cell = target_size / qr_grid;
    union() {
        for (p = qr_modules)
            translate([
                p[0]*cell-qr_module_growth/2,
                (qr_grid-1-p[1])*cell-qr_module_growth/2
            ]) square([cell+qr_module_growth,cell+qr_module_growth]);
    }
}

module card_black_relief() {
    z = card_t - 0.05;
    if (show_qr && qr_ready)
        translate([card_w/2-qr_size/2,11.5,z])
            linear_extrude(height=relief_h) qr_2d(qr_size);
    translate([card_w/2,6.4,z]) linear_extrude(height=relief_h)
        text("扫码 · 看手气",size=3.6,font=font_main,halign="center",valign="center");
}

module heart_card_all() {
    union() {
        card_base();
        card_red_relief();
        card_black_relief();
    }
}

module heart_card_flat_colored() {
    color("#f4ead7") card_base();
    color("#b52b23") card_red_relief();
    color("#181512") card_black_relief();
}

module heart_card_standing_colored() {
    translate([rack_w/2-card_w/2,display_y-0.8,front_h-7.2])
        rotate([90-display_lean,0,0]) heart_card_flat_colored();
}

// ------------------------------------------------------------
// Assembly: only the central Heart A is shown. No demo cards.
// ------------------------------------------------------------
module assembly() {
    color("#eadcc3") rack_base_geometry();
    if (show_score_labels) {
        color("#b52b23") score_scale(score_left_x,"A组",preview=true);
        color("#245b8f") score_scale(score_right_x,"B组",preview=true);
    }
    slider_standing_colored(score_x(score_left_x,3),score_track_z,"#b52b23");
    slider_standing_colored(score_x(score_right_x,8),score_track_z,"#245b8f");
    heart_card_standing_colored();
}

// ------------------------------------------------------------
// Small tolerance coupons
// ------------------------------------------------------------
module slot_test() {
    difference() {
        soft_prism(70,32,12,3,0.7);
        translate([5,8,5]) cube([25,card_slot_w,12]);
        translate([40,8,5]) cube([25,display_slot_w,12]);
    }
}

module slider_test() {
    test_len = 36;
    difference() {
        soft_prism(42,10,20,2.5,0.6);
        score_track_cutter(3,test_len,10,7,31,7);
    }
    translate([51,5,0]) slider();
}

// ------------------------------------------------------------
// Output selector
// ------------------------------------------------------------
if (part=="assembly") assembly();
else if (part=="rack") rack();
else if (part=="heartA") heart_card_all();
else if (part=="heartA_preview") heart_card_flat_colored();
else if (part=="heartA_base") card_base();
else if (part=="heartA_red") card_red_relief();
else if (part=="heartA_black") card_black_relief();
else if (part=="sliderA") slider();
else if (part=="sliderB") slider();
else if (part=="slot_test") slot_test();
else if (part=="slider_test") slider_test();
