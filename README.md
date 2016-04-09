# p5-HackaMol-Roles-SelectionRole

developing this outside the core for a change.

````perl
    my $group = $mol->select_group("chain A .or. chain B");
    my $group = $mol->select_group("chain A .and. resname TYR");
    my $group = $mol->select_group("water");
    my $group = $mol->select_group(".not. water");
    my $group = $mol->select_group("protein");
    my $group = $mol->select_group("sasa > 10");
    
This role will start simple and build from there
