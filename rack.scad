/*
 * Birthday GuanDan rack - integrated parametric model
 * OpenSCAD 2021.01 compatible.
 *
 * part = "assembly" | "rack" | "heartA" | "heartA_base" |
 *        "heartA_red" | "heartA_black" | "dialA" | "dialB" |
 *        "slot_test"
 */

include <qr_data.scad>

$fn = 48;

part = "assembly";
show_preview_cards = true;
show_score_labels = true;
show_qr = true;

// ---------- rack ----------
rack_w = 210;
rack_d = 85;
base_t = 5;
front_d = 21;
front_h = 35;
corner_r = 4;
edge_bevel = 1.0;

tier_d = 16;
tier1_y = 25; tier1_h = 35;
tier2_y = 47; tier2_h = 43;
tier3_y = 69; tier3_h = 51;

card_slot_len = 192;
card_slot_w = 2.4;
card_slot_depth = 10;
card_lean = 12;

display_slot_len = 62;
display_slot_w = 3.8;
display_slot_depth = 10;
display_lean = 8;
display_y = 12;

// score knobs
score_axle_d = 3.4;
score_left_x = 48;
score_right_x = rack_w - 48;
score_z = 17.5;
score_knob_d = 22;
score_ring_r = 14.5;
score_text_size = 2.6;
score_label_size = 4.7;

// ---------- heart A ----------
card_w = 60;
card_h = 90;
card_t = 3.2;
card_r = 5;
relief_h = 0.65;
border_w = 0.65;
qr_size = 30;
font_main = "Microsoft YaHei:style=Bold";
font_latin = "Times New Roman:style=Bold";

levels = ["2","3","4","5","6","7","8","9","10","J","Q","K","A"];

// ------------------------------------------------------------
// 2D helpers
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
    // Four-section hull gives a light bevel and rounded footprint.
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

// ------------------------------------------------------------
// Rack body
// ------------------------------------------------------------
module rack_solid() {
    union() {
        soft_prism(rack_w,rack_d,base_t,corner_r,edge_bevel);
        soft_prism(rack_w,front_d,front_h,corner_r,edge_bevel);
        translate([0,tier1_y,0]) soft_prism(rack_w,tier_d,tier1_h,3,0.8);
        translate([0,tier2_y,0]) soft_prism(rack_w,tier_d,tier2_h,3,0.8);
        translate([0,tier3_y,0]) soft_prism(rack_w,tier_d,tier3_h,3,0.8);
    }
}

module slot_cutter(y,z_top,len,width,depth,lean) {
    translate([rack_w/2,y,z_top-depth/2+1])
        rotate([-lean,0,0])
            cube([len,width,depth+8],center=true);
}

module card_slot_cutters() {
    slot_cutter(tier1_y+tier_d/2,tier1_h,card_slot_len,card_slot_w,card_slot_depth,card_lean);
    slot_cutter(tier2_y+tier_d/2,tier2_h,card_slot_len,card_slot_w,card_slot_depth,card_lean);
    slot_cutter(tier3_y+tier_d/2,tier3_h,card_slot_len,card_slot_w,card_slot_depth,card_lean);
}

module display_slot_cutter() {
    slot_cutter(display_y,front_h,display_slot_len,display_slot_w,display_slot_depth,display_lean);
}

module axle_hole(x,z) {
    translate([x,front_d+1,z])
        rotate([90,0,0]) cylinder(h=front_d+2,d=score_axle_d);
}

module rack_base_geometry() {
    difference() {
        rack_solid();
        card_slot_cutters();
        display_slot_cutter();
        axle_hole(score_left_x,score_z);
        axle_hole(score_right_x,score_z);
    }
}

// Front-face embossed/engraved-like graphics. They extend only 0.55 mm.
module face_text(str,x,z,size=4.5,depth=0.55,font=font_main) {
    translate([x,0.25,z])
        rotate([90,0,0])
            linear_extrude(height=depth)
                text(str,size=size,font=font,halign="center",valign="center");
}

module score_ring_labels(cx,cz) {
    for (i=[0:12]) {
        a = 90 - i*360/13;
        x = cx + score_ring_r*cos(a);
        z = cz + score_ring_r*sin(a);
        // rotate text tangentially on the front face
        translate([x,0.25,z])
            rotate([90,0,0])
                linear_extrude(height=0.5)
                    text(levels[i],size=score_text_size,font=font_main,halign="center",valign="center");
    }
}

module group_label_A() { face_text("A组",21,27,score_label_size,0.55); }
module group_label_B() { face_text("B组",rack_w-21,27,score_label_size,0.55); }
module score_face_details() {
    if (show_score_labels) {
        group_label_A();
        group_label_B();
        score_ring_labels(score_left_x,score_z);
        score_ring_labels(score_right_x,score_z);
    }
}

module rack() {
    union() {
        rack_base_geometry();
        score_face_details();
    }
}

// ------------------------------------------------------------
// Score dial / knob
// ------------------------------------------------------------
module dial_body() {
    difference() {
        union() {
            cylinder(h=3.2,d=score_knob_d,center=false);
            for (a=[0:30:330])
                rotate([0,0,a]) translate([score_knob_d/2,0,1.6])
                    cube([1.2,2.2,3.2],center=true);
        }
        translate([0,0,-0.1]) cylinder(h=5,d=score_axle_d);
    }
}

module dial_pointer(pointer_angle=0) {
    rotate([0,0,pointer_angle]) translate([0,6.2,3.15])
        linear_extrude(height=0.75)
            polygon(points=[[-1.7,0],[1.7,0],[0,4.5]]);
}

module knurled_dial(pointer_angle=0) {
    union() {
        dial_body();
        dial_pointer(pointer_angle);
    }
}

module dial_standing_colored(cx,cz,pointer_angle=0) {
    translate([cx,-3.0,cz]) rotate([90,0,0]) {
        color("#efe2c9") dial_body();
        color("#332b25") dial_pointer(pointer_angle);
    }
}

// ------------------------------------------------------------
// Heart A card
// ------------------------------------------------------------
module heart_2d(s=1) {
    scale([s,s])
    union() {
        translate([-3.2,1.8]) circle(r=3.5);
        translate([ 3.2,1.8]) circle(r=3.5);
        polygon(points=[[-6.5,1.5],[6.5,1.5],[0,-7.0]]);
    }
}

module card_base() {
    linear_extrude(height=card_t)
        rounded_rect_2d(card_w,card_h,card_r);
}

module card_red_relief() {
    z = card_t - 0.05;
    // thin red inner border
    translate([0,0,z])
        linear_extrude(height=relief_h)
            difference() {
                translate([2.4,2.4]) rounded_rect_2d(card_w-4.8,card_h-4.8,3.2);
                translate([3.1,3.1]) rounded_rect_2d(card_w-6.2,card_h-6.2,2.6);
            }
    // top-left A
    translate([7.5,80,z]) linear_extrude(height=relief_h)
        text("A",size=8,font=font_latin,halign="center",valign="center");
    translate([7.5,72.5,z]) linear_extrude(height=relief_h) heart_2d(0.52);
    // center heart
    translate([card_w/2,61,z]) linear_extrude(height=relief_h) heart_2d(1.35);
    // bottom-right mirrored motif
    translate([52.5,10,z]) rotate([0,0,180]) linear_extrude(height=relief_h)
        text("A",size=7,font=font_latin,halign="center",valign="center");
    translate([52.5,17,z]) rotate([0,0,180]) linear_extrude(height=relief_h) heart_2d(0.42);
}

module qr_2d(target_size=30) {
    cell = target_size / qr_grid;
    union() {
        for (p = qr_modules)
            translate([p[0]*cell, (qr_grid-1-p[1])*cell])
                square([cell*1.002, cell*1.002]);
    }
}

module card_black_relief() {
    z = card_t - 0.05;
    if (show_qr && qr_ready)
        translate([card_w/2-qr_size/2,18,z])
            linear_extrude(height=relief_h)
                qr_2d(qr_size);
    translate([card_w/2,11.0,z]) linear_extrude(height=relief_h)
        text("扫一扫 · 看手气",size=3.3,font=font_main,halign="center",valign="center");
}

module heart_card_all() {
    union() {
        card_base();
        card_red_relief();
        card_black_relief();
    }
}

module heart_card_standing() {
    // Local card XY -> world XZ; 8 degree backwards lean.
    translate([rack_w/2-card_w/2,display_y-0.8,front_h-7.2])
        rotate([90-display_lean,0,0])
            heart_card_all();
}

module heart_card_standing_colored() {
    translate([rack_w/2-card_w/2,display_y-0.8,front_h-7.2])
        rotate([90-display_lean,0,0]) {
            color("#f4ead7") card_base();
            color("#b52b23") card_red_relief();
            color("#181512") card_black_relief();
        }
}

// ------------------------------------------------------------
// Preview playing cards (visualization only)
// ------------------------------------------------------------
module preview_card(rank="A", suit="♥", red=true) {
    color("#f7f3ea")
        linear_extrude(height=0.8)
            rounded_rect_2d(56,88,3.5);
    color(red ? "#b52b23" : "#222222") {
        translate([6,78,0.81]) linear_extrude(height=0.12)
            text(rank,size=7,font=font_latin,halign="center",valign="center");
        translate([6,70,0.81]) linear_extrude(height=0.12)
            text(suit,size=6,font=font_main,halign="center",valign="center");
    }
}

module preview_row(y,z,offset=0) {
    ranks=["2","A","K","Q","J","10","9","8","7","6","5","4","3"];
    suits=["♠","♥","♣","♦","♠","♥","♣","♦","♥","♠","♦","♥","♣"];
    for(i=[0:12]) {
        x=8+i*14.4+offset;
        // narrow overlap; each card remains full-size but most is hidden
        translate([x,y,z]) rotate([90-card_lean,0,0])
            scale([0.64,0.64,1]) preview_card(ranks[i],suits[i],(suits[i]=="♥" || suits[i]=="♦"));
    }
}

module preview_cards() {
    // Just enough vertical exposure to judge the silhouette.
    preview_row(tier1_y+tier_d/2-1,tier1_h-6,0);
    preview_row(tier2_y+tier_d/2-1,tier2_h-6,4);
    preview_row(tier3_y+tier_d/2-1,tier3_h-6,0);
}

// ------------------------------------------------------------
// Assembly
// ------------------------------------------------------------
module assembly() {
    color("#eadcc3") rack_base_geometry();
    if (show_score_labels) {
        color("#b52b23") group_label_A();
        color("#245b8f") group_label_B();
        color("#3c332a") {
            score_ring_labels(score_left_x,score_z);
            score_ring_labels(score_right_x,score_z);
        }
    }
    dial_standing_colored(score_left_x,score_z,0);
    // Preview B group at level 7 (index 5).
    dial_standing_colored(score_right_x,score_z,-5*360/13);
    heart_card_standing_colored();
    if(show_preview_cards) preview_cards();
}

// ------------------------------------------------------------
// Small tolerance test
// ------------------------------------------------------------
module slot_test() {
    difference() {
        soft_prism(70,32,12,3,0.7);
        translate([5,8,5]) cube([25,card_slot_w,12]);
        translate([40,8,5]) cube([25,display_slot_w,12]);
    }
}

// ------------------------------------------------------------
// Output selector
// ------------------------------------------------------------
if (part=="assembly") assembly();
else if (part=="rack") rack();
else if (part=="heartA") heart_card_all();
else if (part=="heartA_base") card_base();
else if (part=="heartA_red") card_red_relief();
else if (part=="heartA_black") card_black_relief();
else if (part=="dialA") knurled_dial(0);
else if (part=="dialB") knurled_dial(-5*360/13);
else if (part=="slot_test") slot_test();
