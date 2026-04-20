#!usr/bin/perl
use strict;
use warnings;
use Tk;
use LWP::Simple;
use LWP::UserAgent;
use Tk::JPEG;
require Tk::HList;
require Tk::ROText;

my $get_this_thing;

my $old_image1;
my $old_image2;
my $next_art = -1;
my $display_art = 1;
my $display_text_box = 0;


my @FAILS;
my @NEW;
my %SCORES;

my $worst;


my $starting;

my $viewer_top;
#my $pull_name;
my $ascii_name;
my $search_name;
my $pull_i;
my $distinguisher_cmc;
my $distinguisher_rarity;
my $distinguisher_set;
my $get_front = 1;
my $turn_right = 0;
my $force_image = 0;

my $what = 0;

my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");
$|++;


## to pull in new cards :  goto : https://mtgjson.com/downloads/all-files/#allprintings
## download AllPrintingsCSVFiles
## unzip in same dir as this script


## PULL IN LEGALITY FILE!!!

$|++;
my $ready = 0;
my $breaker = "---------------------------------------------------------------------------";

open(DROPPED,">drops.txt");

my @DATABASE;
my $name_i;    
my $fname_i;
my $flavorname_i;
my $asci_name_i;
my $type_i;       
my $color_i;      
my $mana_cost_i;  
my $power_i;      
my $toughness_i;  
my $text_i;       
my $keywords_i;   
my $manavalue_i;  
my $rarity_i;     
my $supertypes_i; 
my $subtypes_i;
my $avail_i;
my $border_i;
my $funny_i;
my $flavor_i;
my $edhrank_i;
my $salty_i;
my $promotypes_i;
my $layout_i;
my $oversized_i;
my $uuid_i;
my $set_i;


my @THE_SETS;
my $setcode_i;
my $setname_i;



my %LEGAL_HASH;
my $not_hashed = 1;
my @LEGALS;
my $uuid_leg_i;
my $selected_legality_i;
my @last_legal_sets = ("");









my @CARD_IDS;
my $card_id_uuid_i;
my $card_id_scryfallId_i;



my $mw = new MainWindow;
$mw->configure(-title=>'MTG!');


my @ENTRIES;
my @FIELDS;
my @ENABLES;

my @COLORS=("White","Blue","Green","Red","Black");
my @COLOR_M=("W","U","G","R","B");
my @TYPES = ("Artifact","Battle","Creature","Enchantment","Instant","Land","legendary","Planeswalker","Sorcery","Tribal");

my $label;
my $entry;
my $spacer;

my $top_frame     =$mw->Frame()->pack(-side=>'top');
my $bottom_frame  =$mw->Frame()->pack(-side=>'top');

my $left_frame   = $top_frame->Frame()->pack(-side=>'left');
my $right_frame  = $top_frame->Frame()->pack(-side=>'left');
my $right_frameB = $top_frame->Frame()->pack(-side=>'left');

my $right_frame2 = $top_frame->Frame()->pack(-side=>'left');
my $right_frame3 = $top_frame->Frame()->pack(-side=>'left');

#############################################################################################
## legal sets;
my $legality_selected_1 = "commander";
my $legality_selected_2 = "commander";
my $legality_selected_3 = "commander";

my $frame      = $left_frame->Frame()->pack(-side=>'top');

my @LEGAL_CHOICES = qw(alchemy brawl commander duel future gladiator 
                       historic legacy modern oathbreaker oldschool 
                       pauper paupercommander penny pioneer predh 
                       premodern standard standardbrawl timeless vintage);
my $legal_lble = $frame->Label(-text=>"Format",-width=>6)->pack(-side=>'left');                       
my $legalities1 = $frame->Optionmenu(-options=>\@LEGAL_CHOICES,-textvariable=>\$legality_selected_1,-width=>42)->pack(-side=>'left');
my $legalities2 = $frame->Optionmenu(-options=>\@LEGAL_CHOICES,-textvariable=>\$legality_selected_2,-width=>42)->pack(-side=>'left');
my $legalities3 = $frame->Optionmenu(-options=>\@LEGAL_CHOICES,-textvariable=>\$legality_selected_3,-width=>42)->pack(-side=>'left');
&splitter();
push(@last_legal_sets, $legality_selected_1, $legality_selected_2, $legality_selected_3);
#############################################################################################
## name   
my $name_filter;
   $frame      = $left_frame->Frame()->pack(-side=>'top');
my $name       = $frame->Label(-text=>"Name",-width=>6)->pack(-side=>'left');
my $name_entry = $frame->Entry(-textvariable=>\$name_filter,-width=>49)->pack(-side=>'left');

#############################################################################################
## set
my $set_filter;
$frame          = $left_frame->Frame()->pack(-side=>'top');
my $set         = $frame->Label(-text=>"Set",-width=>6)->pack(-side=>'left');
my $set_entry   = $frame->Entry(-textvariable=>\$set_filter,-width=>49)->pack(-side=>'left');

#############################################################################################
## dups
my $eliminate_dups = 1;
$frame      = $left_frame->Frame()->pack(-side=>'top');
my $dups = $frame->Checkbutton(-text=>"No dups",-variable=>\$eliminate_dups)->pack(-anchor => 'w',-side=>'left');


my $mythic =1;
my $rare =1;
my $uncommon =1;
my $common =1;
my $special = 1;

my $specs   = $frame->Checkbutton(-text=>"S",-variable=>\$special)->pack(-anchor => 'w',-side=>'left');
my $mythics = $frame->Checkbutton(-text=>"M",-variable=>\$mythic)->pack(-anchor => 'w',-side=>'left');
my $rares = $frame->Checkbutton(-text=>"R",-variable=>\$rare)->pack(-anchor => 'w',-side=>'left');
my $uncommons = $frame->Checkbutton(-text=>"U",-variable=>\$uncommon)->pack(-anchor => 'w',-side=>'left');
my $commons = $frame->Checkbutton(-text=>"C",-variable=>\$common)->pack(-anchor => 'w',-side=>'left');

&splitter();

#############################################################################################
## color  (must have)
my @MUST_HAVE;

$frame      = $left_frame->Frame()->pack(-side=>'top');
$label = $frame->Label(-text=>"Must BE       :")->pack(-side=>'left');
for my $i (0..$#COLORS){
   my $name = $COLORS[$i];
   my $f1 = $frame->Checkbutton(-text=>$name,-variable=>\$MUST_HAVE[$i])->pack(-anchor => 'w',-side=>'left');
} 
my $space = $frame->Label(-text=>":",-width=>1)->pack(-side=>'left');


#############################################################################################
## color  (allowed to have)
my @ALLOWED_HAVE;

$frame      = $left_frame->Frame()->pack(-side=>'top');
$label = $frame->Label(-text=>"Allowed to be:")->pack(-side=>'left');

for my $i (0..$#COLORS){
   my $name = $COLORS[$i];
   my $f1 = $frame->Checkbutton(-text=>$name,-variable=>\$ALLOWED_HAVE[$i])->pack(-anchor => 'w',-side=>'left');
} 
$space = $frame->Label(-text=>":",-width=>1)->pack(-side=>'left');

#############################################################################################
## color  (CANT have)
my @NOT_ALLOWED_HAVE;

$frame      = $left_frame->Frame()->pack(-side=>'top');
$label = $frame->Label(-text=>"Not Allowed: ")->pack(-side=>'left');

for my $i (0..$#COLORS){
   my $name = $COLORS[$i];
   my $f1 = $frame->Checkbutton(-text=>$name,-variable=>\$NOT_ALLOWED_HAVE[$i])->pack(-anchor => 'w',-side=>'left');
} 
$space = $frame->Label(-text=>":",-width=>1)->pack(-side=>'left');

&splitter();

#############################################################################################
my $high_power;
my $low_power;
$frame = $left_frame->Frame()->pack(-side=>'top');
$label = $frame->Label(-text=>"Power:")->pack(-side=>'left');
$entry = $frame->Entry(-textvariable=>\$low_power,-width=>5)->pack(-side=>'left');
$name  = $frame->Label(-text=>"to:")->pack(-side=>'left');
$entry = $frame->Entry(-textvariable=>\$high_power,-width=>5)->pack(-side=>'left');

#############################################################################################
my $high_toughness;
my $low_toughness;
$label = $frame->Label(-text=>"Toughness:")->pack(-side=>'left');
$entry = $frame->Entry(-textvariable=>\$low_toughness,-width=>5)->pack(-side=>'left');
$name  = $frame->Label(-text=>"to")->pack(-side=>'left');
$entry = $frame->Entry(-textvariable=>\$high_toughness,-width=>5)->pack(-side=>'left');
$space = $frame->Label(-text=>":",-width=>10)->pack(-side=>'left');
&splitter();


#############################################################################################
## cost
my $low;
my $high;
$frame  = $left_frame->Frame()->pack(-side=>'top');
$label  = $frame->Label(-text=>"Converted mana cost:  ")->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$low,-width=>5)->pack(-side=>'left');
$label  = $frame->Label(-text=>" to ")->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$high,-width=>5)->pack(-side=>'left');
$space  = $frame->Label(-text=>"       ",-width=>18)->pack(-side=>'left');
&splitter();

#############################################################################################
## sub types;
my $subtype = "";

#my $type;
$frame = $left_frame->Frame()->pack(-side=>'top');
$label  = $frame->Label(-text=>"subtype:")->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$subtype,-width=>10)->pack(-side=>'left');



#############################################################################################
## super types;
my $super_type = "";

#$frame = $left_frame->Frame()->pack(-side=>'top');
$label  = $frame->Label(-text=>"super type:")->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$super_type,-width=>10)->pack(-side=>'left');
 $space  = $frame->Label(-text=>"       ",-width=>10)->pack(-side=>'left');

&splitter();
#############################################################################################
my @ALLOWED_TYPES;

   $frame  = $left_frame->Frame()->pack(-side=>'top');
my $frame1 = $left_frame->Frame()->pack(-side=>'top');
my $frame2 = $left_frame->Frame()->pack(-side=>'top');

$label  = $frame->Label(-text=>"-----allowed types------")->pack(-side=>'left');
for my $i (0..$#TYPES){
   my $name = $TYPES[$i];
   if($i < 5){
      my $f1 = $frame1->Checkbutton(-text=>$name,-variable=>\$ALLOWED_TYPES[$i])->pack(-anchor => 'w',-side=>'left');
   } else {
      my $f1 = $frame2->Checkbutton(-text=>$name,-variable=>\$ALLOWED_TYPES[$i])->pack(-anchor => 'w',-side=>'left');
   }
}
&splitter();
#############################################################################################
my @NOT_ALLOWED_TYPES;

$frame  = $left_frame->Frame()->pack(-side=>'top');
$frame1 = $left_frame->Frame()->pack(-side=>'top');
$frame2 = $left_frame->Frame()->pack(-side=>'top');

$label  = $frame->Label(-text=>"-----NOT allowed types------")->pack(-side=>'left');
for my $i (0..$#TYPES){
   my $name = $TYPES[$i];
   if($i < 5){
      my $f1 = $frame1->Checkbutton(-text=>$name,-variable=>\$NOT_ALLOWED_TYPES[$i])->pack(-anchor => 'w',-side=>'left');
   } else {
      my $f1 = $frame2->Checkbutton(-text=>$name,-variable=>\$NOT_ALLOWED_TYPES[$i])->pack(-anchor => 'w',-side=>'left');
   }
} 
&splitter();
#############################################################################################
## text
my $text1;
my $text2;
my $text3;
my $text4;
my $text5;
my $text6;
my $text7;
my $text8;

$frame  = $left_frame->Frame()->pack(-side=>'top');
$frame1 = $left_frame->Frame()->pack(-side=>'top');
$frame2 = $left_frame->Frame()->pack(-side=>'top');

$label  = $frame->Label(-text=>"TEXT ANDS:")->pack(-side=>'left');
$entry  = $frame1->Entry(-textvariable=>\$text1,-width=>10)->pack(-side=>'left');
$entry  = $frame1->Entry(-textvariable=>\$text2,-width=>10)->pack(-side=>'left');
$entry  = $frame1->Entry(-textvariable=>\$text3,-width=>10)->pack(-side=>'left');
$entry  = $frame1->Entry(-textvariable=>\$text4,-width=>10)->pack(-side=>'left');

$entry  = $frame2->Entry(-textvariable=>\$text5,-width=>10)->pack(-side=>'left');
$entry  = $frame2->Entry(-textvariable=>\$text6,-width=>10)->pack(-side=>'left');
$entry  = $frame2->Entry(-textvariable=>\$text7,-width=>10)->pack(-side=>'left');
$entry  = $frame2->Entry(-textvariable=>\$text8,-width=>10)->pack(-side=>'left');
&splitter();

#############################################################################################
## or text
my @OR_TEXT;
$OR_TEXT[0]="";
$OR_TEXT[1]="";
$OR_TEXT[2]="";
$OR_TEXT[3]="";


$frame  = $left_frame->Frame()->pack(-side=>'top');
$label  = $frame->Label(-text=>"TEXT ORS:")->pack(-side=>'left');
$frame  = $left_frame->Frame()->pack(-side=>'top');

$entry  = $frame->Entry(-textvariable=>\$OR_TEXT[0],-width=>10)->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$OR_TEXT[1],-width=>10)->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$OR_TEXT[2],-width=>10)->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$OR_TEXT[3],-width=>10)->pack(-side=>'left');


#############################################################################################
## not text
my $ntext1;
my $ntext2;
my $ntext3;
my $ntext4;

$frame  = $left_frame->Frame()->pack(-side=>'top');
$frame1 = $left_frame->Frame()->pack(-side=>'top');
$frame2 = $left_frame->Frame()->pack(-side=>'top');

$label  = $frame->Label(-text=>"TEXT NOTS:")->pack(-side=>'left');
$entry  = $frame1->Entry(-textvariable=>\$ntext1,-width=>10)->pack(-side=>'left');
$entry  = $frame1->Entry(-textvariable=>\$ntext2,-width=>10)->pack(-side=>'left');
$entry  = $frame1->Entry(-textvariable=>\$ntext3,-width=>10)->pack(-side=>'left');
$entry  = $frame1->Entry(-textvariable=>\$ntext4,-width=>10)->pack(-side=>'left');


#############################################################################################
## sort by; 
$frame  = $left_frame->Frame()->pack(-side=>'top');
my @SORT_BY = ("CMC","EDH Rank","Salty");
my $sort_by = $SORT_BY[0];

for my $i (0..$#SORT_BY){
   my $name = $SORT_BY[$i];
   my $f1 = $frame->Radiobutton(-text=>$name,-value=>$name,-variable=>\$sort_by)->pack(-anchor => 'w',-side=>'left');
} 


#############################################################################################

my @MAP;

my $scrollbar   = $right_frame->Scrollbar( );
my $hlist       = $right_frame->HList(-height=>28,-width=>44,-browsecmd=>\&hlist_select_call,-selectmode => "single",-yscrollcommand => ['set' => $scrollbar],-font=>'courier 10',)->pack(-side=>'left');
$scrollbar->configure(-command => ['yview' => $hlist]);
$scrollbar->pack(-side => 'right', -fill => 'y');
$hlist->pack(-side => 'left', -fill => 'both');

#############################################################################################

my @WORKING;
my @MAP2;
my $scrollbar2   = $right_frameB->Scrollbar( );
my $hlist2       = $right_frameB->HList(-height=>28,-width=>40,-browsecmd=>\&hlist2_select_call,-selectmode => "single",-yscrollcommand => ['set' => $scrollbar2],-font=>'courier 10',)->pack(-side=>'left');
$scrollbar2->configure(-command => ['yview' => $hlist2]);
$scrollbar2->pack(-side => 'right', -fill => 'y');
$hlist2->pack(-side => 'left', -fill => 'both');




#############################################################################################
my $text_panel;
if($display_text_box){
    $right_frame2->ROText(
            -height=>28,
            -width=>40,
            -font=>'courier 10',
            )->pack(-side=>'top');
}
##################################################################################

my $search;
my $status = "Not ready";

my $jank_edh_rank = 15000;

my $next_frame=$left_frame->Frame()->pack(-side=>'top');
$next_frame=$left_frame->Frame()->pack(-side=>'top');
my $button=$left_frame->Button(-text=>"Search",-command=>[\&commands, "search"])->pack(-side=>'left');
   $button=$left_frame->Button(-text=>"Random",-command=>[\&commands, "random"])->pack(-side=>'left');
   $button=$left_frame->Button(-text=>"Jank",-command=>[\&commands, "random jank"])->pack(-side=>'left');
   $button=$left_frame->Button(-text=>"Neighbors",-command=>[\&commands, "find_sim"])->pack(-side=>'left');
   $button=$left_frame->Button(-text=>"Add",-command=>[\&commands, "add to list"])->pack(-side=>'left');
   $button=$left_frame->Button(-text=>"Remove",-command=>[\&commands, "remove to list"])->pack(-side=>'left');
   $button=$left_frame->Button(-text=>"download",-command=>[\&commands, "download"])->pack(-side=>'left');
   
   
   

$button=$left_frame->Button(-text=>"Clear",-command=>[\&commands, "Clear"])->pack(-side=>'left');
my $stat=$left_frame->Label(-textvariable=>\$status)->pack(-side=>'left');

my $image_lbl = $right_frame3->Label()->pack(-side=>'top');
my $flip_button = $right_frame3->Button(-text=>'flip',-command=>[\&commands, "flip"],-width=>25)->pack(-side=>'left');
my $rotate_right = $right_frame3->Button(-text=>'Rot right',-command=>[\&commands, "right_turn"],-width=>25)->pack(-side=>'left');

`mkdir ART2 > NUL 2>&1`;
$mw->after(1000,\&init);
MainLoop;


##################################################################################
sub commands{
   my ($cmd) = @_;
   
   if(!$ready){
      print "I am not ready yet!\n";
      return;
   }
   if($cmd eq "Clear"){
      $name_filter = "";
      $low_power = "";
      $high_power = "";
      $high_toughness= "";
      $low_toughness = "";
      $low = "";
      $high = "";
      $subtype = "";
      $super_type = "";
      for my $i (0..$#TYPES){
         $ALLOWED_TYPES[$i] = 0;
      }
      for my $i (0..$#TYPES){
         $NOT_ALLOWED_TYPES[$i] = 0;
      }
      for my $i (0..$#COLORS){
         $MUST_HAVE[$i] = 0;
         $ALLOWED_HAVE[$i] = 0;
         $NOT_ALLOWED_HAVE[$i] = 0;
      }
      
      $text1 ="";
      $text2 ="";
      $text3 ="";
      $text4 ="";
      $text5 ="";
      $text6 ="";
      $text7 ="";
      $text8 ="";
      $OR_TEXT[0]="";
      $OR_TEXT[1]="";
      $OR_TEXT[2]="";
      $OR_TEXT[3]="";
      $ntext1 = "";
      $ntext2 = "";
      $ntext3 = "";
      $ntext4 = "";
      
      $mw->update();
   } elsif($cmd eq "find_sim"){
      &find_similair();
      
   } elsif($cmd eq "add to list"){
      &add_to_working();
      #&hlist2_select_call($#WORKING);

   
   
   } elsif($cmd eq "remove to list"){
      &remove_from_working();
      
   } elsif($cmd eq "download"){
      $next_art = 0;
      $display_art = 0;
      &download_art();
      
   } elsif($cmd eq "flip"){
       $get_front = !$get_front;
       $turn_right = 0;
       $force_image =1;
       $mw->after(1,\&get_art_and_display);
       
   } elsif($cmd eq "right_turn"){
       $turn_right = !$turn_right;
       #$force_image =1;
       $mw->after(1,\&get_art_and_display);
       
   } elsif($cmd eq "random"){
     &pick_a_random_card(0);
   
   } elsif($cmd eq "find_sim"){
     &find_sim();
     
   } elsif($cmd eq "random jank"){
     &pick_a_random_card(1);
   
   
   } elsif($cmd eq "search"){
       ## check  name_filter
       ## check MUST_HAVE
       ## check ALLOWED_HAVE
       ## $high_power = 99;
       ## $low_power = 0;
       ## $low  to $high     (cost)
       ## super_type and $type
       my @LIST;
       my @NEW_LIST;
       my $d;
       for my $i (1..$#DATABASE){
          push(@LIST,$i);
       }
       $d = $#LIST;
       print "Staring from $d\n";
              
       @LIST = &filter_on_legal(@LIST);
       $d = $#LIST;
       print "after command legality $d\n";
       
       @LIST = &filter_on_sets($set_filter,@LIST);
       $d = $#LIST;
       print "after filter_on_sets $d\n";
       
       @LIST = &filter_on_rarity(@LIST);
       $d = $#LIST;
       print "after rarity $d\n";
       
       
       
       ########################################
       ## name filter
       @LIST = &filter_on_name($name_filter,@LIST);
       $d = $#LIST;
       print "After name filter $d\n";
       
       ########################################
       ## must haves;
       @LIST = &filter_on_must_color(@LIST);
       $d = $#LIST;       
       print "After must have filter $d\n";
       
       ########################################
       ## must not haves;
       @LIST = &filter_on_not_allowed_color(@LIST);
       $d = $#LIST;       
       print "After must not have filter $d\n";       
       
       
       ########################################
       ## allowed to be;
       @LIST = &filter_on_allowed_color(@LIST);
       $d = $#LIST;       
       print "After must have filter $d\n";
       
       ########################################
       ## power / toughness;
       @LIST = &filter_on_power_toughness(@LIST);
       $d = $#LIST;       
       print "After power toughness filter $d\n";
       
       ########################################
       ## mana cost;
       @LIST = &filter_on_mana_cost(@LIST);
       $d = $#LIST;       
       print "After mana cost filter $d\n";
       
       ########################################
       ## types;
       print "filtering types vs\n";
       @LIST = &filter_on_types(@LIST);
       $d = $#LIST;       
       print "After types filter $d\n";
       
       ########################################
       ## types;
       @LIST = &filter_not_types(@LIST);
       $d = $#LIST;       
       print "After not types filter $d\n";

       ########################################
       ## text;
       @LIST = &filter_on_text($text1,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       ## text;
       @LIST = &filter_on_text($text2,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 

       ## text;
       @LIST = &filter_on_text($text3,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       ## text;
       @LIST = &filter_on_text($text4,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       ## text;
       @LIST = &filter_on_text($text5,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       ## text;
       @LIST = &filter_on_text($text6,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       ## text;
       @LIST = &filter_on_text($text7,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       ## text;
       @LIST = &filter_on_text($text8,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       ########################################
       ## not text;
       ## text;
       @LIST = &filter_not_text($ntext1,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       @LIST = &filter_not_text($ntext2,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       @LIST = &filter_not_text($ntext3,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       @LIST = &filter_not_text($ntext4,@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       ########################################
       ## or checks       
       @LIST = &filter_or_text(@LIST);
       $d = $#LIST;       
       print "After text filter $d\n"; 
       
       ########################################
       ## subtye type;
       @LIST = &filter_on_subtype(@LIST);
       $d = $#LIST;       
       print "After super_type filter $d\n"; 
       
       ########################################
       ## super type;
       @LIST = &filter_on_supertype(@LIST);
       $d = $#LIST;       
       print "After supertype filter $d\n"; 
       
       ########################################
       if($eliminate_dups){
          @LIST = &clip_dups(@LIST);
          $d = $#LIST;       
          print "After dups filter $d\n"; 
       }
       

       print "*****************************************\n";
       $d = $#LIST+1;
       print "Found $d matches\n";
       for my $i (@LIST){
          my $uuid = $DATABASE[$i][$uuid_i];
         # my $legal = $LEGAL_HASH{$uuid};
          my $border = $DATABASE[$i][$border_i];
          my $funny  = $DATABASE[$i][$funny_i];
          print "$i -> $border || $funny || $uuid || $DATABASE[$i][$name_i]\n";
       }
       print "Found $d matches\n";
       
       my @SORTED;
       if($sort_by eq "CMC"){
          ## sort by cmc;
          my @SORT;
          for my $i (@LIST){
             my $cmc = $DATABASE[$i][$manavalue_i];
             my $sortname = chr(int($cmc)+ord("A"))."_".$DATABASE[$i][$name_i]."XXX".$i;
             push(@SORT,$sortname);
          }
          @SORTED=sort(@SORT);
          @MAP = ();
          $hlist->delete('all');
          for my $place (0..$#SORTED){
             my $this = $SORTED[$place];
             if($this =~ /(\w)\_(.*)XXX(\d+)/){
                my $cmc = $1;
                my $name = $2;
                my $index = $3;                
                my $display_string = &build_string_for($index);
                                
                $MAP[$place] = $index;
                $hlist->add($place ,-text=>$display_string);
             } else {
                print "Fail $this\n";
             }
          }
       } elsif($sort_by eq "EDH Rank") {
          my @SORT;       
       
          ## sort by edhrank_i;
          for my $i (@LIST){
             my $sort_name = sprintf("%8i:%i",$DATABASE[$i][$edhrank_i],$i);
             push(@SORT,$sort_name);
          }   
          @SORTED = sort { substr($a,0, 8) <=> substr($b,0, 8)  } @SORT;
          @MAP = ();
          $hlist->delete('all');
          for my $place (0..$#SORTED){
             my $this = $SORTED[$place];
             if($this =~ /(\d+)\:(\d+)/){
                my $edhrank = $1;
                my $index   = $2;
                $MAP[$place] = $index;
                $name = $DATABASE[$index][$name_i];
                $hlist->add($place ,-text=>$name);
             } else {
                print "Fail $this\n";
             }
          }
       } elsif($sort_by eq "Salty"){
          my @SORT;       
       
          ## sort by edhrank_i;
          for my $i (@LIST){
             my $start_from = $DATABASE[$i][$salty_i];
             if($start_from eq ""){
                $start_from = 0;
             }
             my $salt = 1000 - int($start_from*100);
             my $sort_name = sprintf("%8i:%i",$salt,$i);
             push(@SORT,$sort_name);
          }   
          @SORTED = sort { substr($a,0, 8) <=> substr($b,0, 8)  } @SORT;
          @MAP = ();
          $hlist->delete('all');
          for my $place (0..$#SORTED){
             my $this = $SORTED[$place];
             if($this =~ /(\d+)\:(\d+)/){
                my $edhrank = $1;
                my $index   = $2;
                $MAP[$place] = $index;
                $name = $DATABASE[$index][$name_i];
                $hlist->add($place ,-text=>$name);
             } else {
                print "Fail $this\n";
             }
          }
       }

    #   &dump_list(@SORTED);
       &hlist_select_call(0);
   }
}

###############################################################################
sub pick_out_soup{

   ## start from starting;
   ## xxx
   my $text = $DATABASE[$starting][$text_i];
   
   $text =~ s/\(.*\)//g;
   
   $text =~ s/\\n/ /g;
   $text =~ s/\s+/ /g;
   $text =~ s/\,//g;
   $text =~ s/\.//g;
   
   $text =~ s/\sis\s/ /g;
   $text =~ s/\sthe\s/ /g;
   $text =~ s/\sa\s/ /g;
   $text =~ s/\sthis\s/ /g;
   $text =~ s/\sof\s/ /g;
   $text =~ s/\sto\s/ /g;
   $text =~ s/\sit\s/ /g;
   $text =~ s/\sthat\s/ /g;
   $text =~ s/\san\s/ /g;

   my @S = split(/\s+/,$text);
   my @OUT;
   for my $s (@S){
      my $found =0;
      for my $o (@OUT){
         if(lc($o) eq lc($s)){
            $found =1;
         }
      }
      if(!$found){
         push(@OUT,lc($s));
      }
   }
   return @OUT;
   
   
} ## xxx


###############################################################################
sub get_score{
   my ($i,@SOUP) = @_;
   
   my $text = lc($DATABASE[$i][$text_i]);
   $text =~ s/\,//g;
   $text =~ s/\.//g;

   my @WORDS = split(/\s+/,$text);
   my $match = 0;
   my $score = 0;
   for my $check (@SOUP){
      my $found = 0;
      for my $word (@WORDS){
         if($found == 0){
            if($word eq $check){
                $match++;
                $score += ($SCORES{$word});
                $found = 1;
            }
         }
      }
   } 
   return $score*$match;
}

###############################################################################
sub init_working{
   my $failed = 0;
   open(WORKING,"working_set.txt") or $failed = 1;
   if($failed == 0){
      while(<WORKING>){
         my $line = $_;
         chomp($line);
         if($line =~ /^(\d+)\:/){
            push(@WORKING,$1);
         }
      }   

      &redisplay_working();
   }
}

###############################################################################
sub add_to_working{
   push(@WORKING,$starting);
   &redisplay_working();
}

###############################################################################
sub redisplay_working{
   $hlist2->delete('all');
   
   my $place = 0;
   for my $i (@WORKING){
      my $display_string = &build_string_for($i);
      $MAP2[$place] = $i;
      $hlist2->add($place ,-text=>$display_string);
      $place++;
   }
   
   open(WORKING,">working_set.txt");
   for my $i (@WORKING){
      print WORKING "$i:$DATABASE[$i][$name_i]\n";
   }
   close(WORKING);
   
   


} 

###############################################################################
sub download_art{

   &hlist_select_call($next_art);
   
   $next_art++;
}
###############################################################################
sub remove_from_working{

   my @TEMP = @WORKING;
   @WORKING = ();
   for my $i (@TEMP){
      if($i != $starting){
         push(@WORKING,$i);
      }   
   }

   &redisplay_working();

}
###############################################################################
sub find_similair{

   my @LIST;
   for my $i (1..$#DATABASE){
      push(@LIST,$i);
   }
              
   @LIST = &filter_on_legal(@LIST);
   @LIST = &filter_on_must_color(@LIST);
   @LIST = &filter_on_not_allowed_color(@LIST);
   @LIST = &filter_on_allowed_color(@LIST);
   @LIST = &filter_on_types(@LIST);
   @LIST = &filter_not_types(@LIST);
   @LIST = &filter_on_subtype(@LIST);
   @LIST = &filter_on_supertype(@LIST);
   @LIST = &clip_dups(@LIST);
   
   ## now use what this card has to specify; text filters from here;
   my @SOUP = &pick_out_soup();

   ## need at least 3 words; to make cut;
   my @FOUND;
   
   for my $i (@LIST){
      my $score = &get_score($i,@SOUP);
      my $string = sprintf("%8i:%i",$score,$i);
      push(@FOUND,$string);
   }
   my @SORTED = sort { substr($a,0, 8) <=> substr($b,0, 8)  } @FOUND;
   @LIST = ();
   my $text = $DATABASE[$starting][$text_i];

   @SORTED=reverse(@SORTED);
   for my $each (@SORTED){
      if($each =~ /(\d+)\:(\d+)/){
         my $score = $1;
         my $this  = $2;
         if($score > 0){
            push(@LIST,$this);
         }
      }
   }   
   
   @LIST = &clip_dups(@LIST);
   $hlist->delete('all');
   
   my $place = 0;
   for my $i (@LIST){
      my $display_string = &build_string_for($i);
      $MAP[$place] = $i;
      $hlist->add($place ,-text=>$display_string);
      $place++;
   }
   &hlist_select_call(0);
}
###############################################################################

sub build_string_for{
   my ($i) = @_;
   
   my $cmc  = $DATABASE[$i][$manavalue_i];
   my $name = $DATABASE[$i][$name_i];
   my $colors = $DATABASE[$i][$color_i];
   
   $colors =~ s/\s//g;
   $colors =~ s/\,//g;
   
   return sprintf("%2i %-5s %-s",$cmc,$colors,$name);
   
}   

##################################################################################
sub splitter{
  # my $frame      = $left_frame->Frame()->pack(-side=>'top');
  #my $label      = $frame->Label(-textvariable=>\$breaker)->pack(-side=>'left');
   

}

##################################################################################
sub generate_dist_oracle_text{
   my ($i) = @_;
   
  # my $tag_for_each = "+oracle%3A";
   my $text = $DATABASE[$i][$text_i];
   
   my $use = substr($text,0,10);
   
   print "incoming i = $i; and TEXT=\n";
   print "$text\n";
   print "Using $use\n";
   
   return $use;

}
##################################################################################
sub hlist2_select_call{
   my ($what) = @_;
   &hlist_select_call($what,2);

}
##################################################################################
sub clean_name_for_dos{
   my ($text) = @_;
   $text =~ s/[^\x00-\x7f]//g;
   $text=~ s/\s+//g;
   $text=~ s/\,/\_/g;
   $text=~ s/\\/\_/g;
   $text=~ s/\//\_/g;
   
   
   
   return $text;
}
##################################################################################
sub hlist_select_call{
   my ($what,$which_map) = @_;
   
   if(defined($which_map)){
      if($which_map == 2){
         $what = $MAP2[$what];
      } else {
         $what = $MAP[$what];      
      }
   } else {
      $what = $MAP[$what];
   }   
   $starting = $what;   
   
   if($display_text_box){
      $text_panel->delete('0.0','end');
   }

   my $text = "";
   my $i = $what;
   my $actual = &get_setname($DATABASE[$i][$set_i]);

   my $fname = $DATABASE[$i][$fname_i];
   my $name  = $DATABASE[$i][$name_i];
   $ascii_name = $DATABASE[$i][$asci_name_i];
   if($ascii_name =~ /\w/){
   } else {
      $ascii_name = $name;
   }
   print "name = $ascii_name =>";
   $ascii_name = &clean_name_for_dos($ascii_name);
   print "name = $ascii_name\n";

   my $uuid = $DATABASE[$i][$uuid_i];
   print "UUID=$uuid\n";
   $get_this_thing = &get_download_name_for_uuid($uuid);
   my $flavor_name = $fname;
   if($flavor_name ne ""){
      $name = "$flavor_name. aka $name";
   } elsif($fname ne ""){
      $name = "$fname aka $name";
   }


   $text .=  &split_up_text($name)."\n";
   $text .=  $DATABASE[$i][$type_i]."\n";
   $text .=  $DATABASE[$i][$color_i]."\n";
   $text .=  $DATABASE[$i][$mana_cost_i]."\n\n";
   my $p = $DATABASE[$i][$power_i];
   my $t = $DATABASE[$i][$toughness_i];
   if(($p ne "") || ($t ne "")){
      $text .= "$DATABASE[$i][$power_i] / $DATABASE[$i][$toughness_i]\n";
   }
   $text .= "CMC : $DATABASE[$i][$manavalue_i]\n";
   $text .= "$DATABASE[$i][$rarity_i]\n";
   $text .= "$DATABASE[$i][$supertypes_i]\n";
   $text .= "$DATABASE[$i][$subtypes_i]\n";
   $text .= "Salt = $DATABASE[$i][$salty_i]\n";
   $text .= "EDHRANK = $DATABASE[$i][$edhrank_i]\n";
   $text .= "---------------------------------------\n";
   if($display_text_box){
      $text_panel->insert('end',$text);
   }

   my $card_text = $DATABASE[$i][$text_i];
   $card_text =~ s/\\n/\n/g;
   my @LINES = split(/\n/,$card_text);

   if($display_text_box){
      for my $line (@LINES){
         my $this = &split_up_text($line);
         if($this ne ""){
            $this .= "\n\n";

            $text_panel->insert('end',$this);
            $this = "";
         }
      }

      $text_panel->insert('end',"Set is \"$actual\"\n");
      $text_panel->insert('end',"Flavor:\n");
      my $flavor = &split_up_text($DATABASE[$i][$flavor_i]);
      $text_panel->insert('end',"$flavor\n");
   }

   $get_front = 1;
   $turn_right = 0;

   $mw->after(1,\&get_art_and_display);
    
}
##################################################################################
sub split_up_text{
   my ($text) = @_;
   my @C = split(/\s+/,$text);
   my $this = "";
   my $first = 1;
   my $max = 40;

   for my $c (@C){
      my $new_length = length($this) +1 +length($c);
      if($new_length > $max){
         $this .= "\n";
         if($display_text_box){
            $text_panel->insert('end',$this);
         }
         $this = $c;
      } else {
         if($first){
            $this .= $c;
            $first = 0;
         } else {
            $this .= " ".$c;
         }
      }
   }
   return $this;
}

##################################################################################
sub filter_on_words{
    my ($word,@LIST) = @_;
    if((!defined($word)) || ($word eq "")){return @LIST;}
    my @NEW_LIST;
    for my $i (@LIST){
       my $this = $DATABASE[$i][$text_i];
       if($this =~ /\s*$word\s*/i){
          push(@NEW_LIST,$i);
       }   
    }
    return @NEW_LIST;
}

##################################################################################
sub filter_on_text{
    my ($pattern,@LIST) = @_;
    if((!defined($pattern)) || ($pattern eq "")){return @LIST;}
    my @NEW_LIST;
    for my $i (@LIST){
       my $this = $DATABASE[$i][$text_i];
       if($this =~ /$pattern/i){
          push(@NEW_LIST,$i);
       }   
    }
    return @NEW_LIST;
}
##################################################################################
sub filter_not_text{
    my ($pattern,@LIST) = @_;
    if((!defined($pattern)) || ($pattern eq "")){return @LIST;}
    my @NEW_LIST;
    for my $i (@LIST){
       my $this = $DATABASE[$i][$text_i];
       if($this !~ /$pattern/i){
          push(@NEW_LIST,$i);
       }   
    }
    return @NEW_LIST;

}

##################################################################################
sub filter_or_text{
   my (@LIST) = @_;
   ## slide them left;
   
   my @NEW_LIST;
   
   for my $j (1..3){
      for my $i (0..3){
         if($OR_TEXT[$i] eq ""){
            $OR_TEXT[$i] = $OR_TEXT[$i+1];
            $OR_TEXT[$i+1] = "";
         }
      }   
   }
   my $z = 0;
   for my $i (0..3){
      if($OR_TEXT[$i] ne ""){
         $z++;
      }
   }
   if($z == 0){
      return @LIST;
   }
   
   for my $i (@LIST){
      my $this = $DATABASE[$i][$text_i];
      my $pass = 0;
      for my $j (0..$z-1){
         if($this =~ /$OR_TEXT[$j]/){
            $pass = 1;
         }
      }
      if($pass){
         push(@NEW_LIST,$i);
      }   
   }
   
   return @NEW_LIST;
}
##################################################################################
sub filter_on_supertype{
    my (@LIST) = @_;
    my @NEW_LIST;
    if($super_type eq ""){return @LIST;}
        
    for my $i (@LIST){
       my $this = $DATABASE[$i][$supertypes_i];
       if($this =~ /$super_type/i){
          push(@NEW_LIST,$i);
       }   
    }
    return @NEW_LIST;
}
##################################################################################
sub filter_on_subtype{
    my (@LIST) = @_;
    my @NEW_LIST;
    if($subtype eq ""){return @LIST;}
        
    for my $i (@LIST){
       my $this = $DATABASE[$i][$subtypes_i];
       if($this =~ /$subtype/i){
          push(@NEW_LIST,$i);
       }   
    }
    return @NEW_LIST;



}
##################################################################################
sub filter_on_types{
    my (@LIST) = @_;
    my @NEW_LIST;
    my @CHECK;
    my $found = 0;
    for my $i (0..$#ALLOWED_TYPES){
       if($ALLOWED_TYPES[$i]){
          $found++;
          push(@CHECK,$TYPES[$i]);
       }   
    }
    if($found == 0){return @LIST;}
    for my $i (@LIST){
       my $this = $DATABASE[$i][$type_i];
       my $good = 0;
       for my $check (@CHECK){
          if($this =~ /$check/i){
             $good = 1;
          }
       }   
       if($good){
          push(@NEW_LIST,$i);
       }   
    }
    return @NEW_LIST;
}

##################################################################################
sub filter_not_types{
    my (@LIST) = @_;
    my @NEW_LIST;
    my @CHECK;
    my $found = 0;
    for my $i (0..$#NOT_ALLOWED_TYPES){
       if($NOT_ALLOWED_TYPES[$i]){
          $found++;
          push(@CHECK,$TYPES[$i]);
       }   
    }
    if($found == 0){return @LIST;}
    for my $i (@LIST){
       my $this = $DATABASE[$i][$type_i];
       my $good = 1;
       for my $check (@CHECK){
          if($this =~ /$check/i){
             $good = 0;
          }
       }   
       if($good){
          push(@NEW_LIST,$i);
       }   
    }
    return @NEW_LIST;
}

##################################################################################
sub filter_on_mana_cost{
    my (@LIST) = @_;
    
    if((defined($low)) && ($low =~ /\d/)){
       my @NEW_LIST;
       for my $i (@LIST){
          if(&valid_numeric($DATABASE[$i][$manavalue_i])){
             my $cost = $DATABASE[$i][$manavalue_i];
             if($cost >= $low){
                push(@NEW_LIST,$i);
             }   
          }
       }
       @LIST=@NEW_LIST;
       @NEW_LIST = ();
    }
    if((defined($high)) && ($high =~ /\d+/)){
       my @NEW_LIST;
       for my $i (@LIST){
          if(&valid_numeric($DATABASE[$i][$manavalue_i])){
             my $cost = $DATABASE[$i][$manavalue_i];
             if($cost <= $high){
                push(@NEW_LIST,$i);
             }   
          }
       }
       @LIST=@NEW_LIST;
       @NEW_LIST = ();
    }
    return @LIST;

}
##################################################################################
sub filter_on_power_toughness{
    my (@LIST) = @_;
    #print "high_power     :$high_power:\n";
    #print "low_power      :$low_power:\n";
    #print "high_toughness :$high_toughness:\n";
    #print "low_toughness  :$low_toughness:\n";
    
    
    if((defined($high_power)) && ($high_power =~ /\d/)){
       my @NEW_LIST;
    
       for my $i (@LIST){
          if(&valid_numeric($DATABASE[$i][$power_i])){
             my $power = $DATABASE[$i][$power_i];
             if($power =~ /\*/){
                push(@NEW_LIST,$i);
             } elsif($power <= $high_power){
                push(@NEW_LIST,$i);
             }   
          }
       }
       @LIST=@NEW_LIST;
       @NEW_LIST = ();
    }
    
    if((defined($low_power)) && ($low_power =~ /\d/)){
       my @NEW_LIST;
    
       for my $i (@LIST){
          if(&valid_numeric($DATABASE[$i][$power_i])){
             my $power = $DATABASE[$i][$power_i];
             if($power =~ /\*/){
                push(@NEW_LIST,$i);
             } elsif($power >=$low_power){
                push(@NEW_LIST,$i);
             }
          }
       }
       @LIST=@NEW_LIST;
       @NEW_LIST = ();    
    }
    if(defined(($high_toughness)) && ($high_toughness =~ /\d/)){
       my @NEW_LIST;
    
       for my $i (@LIST){
          if(&valid_numeric($DATABASE[$i][$toughness_i])){
             my $tough = $DATABASE[$i][$toughness_i];
             if($tough =~ /\*/){
                push(@NEW_LIST,$i);
             } elsif($tough <= $high_power){
                push(@NEW_LIST,$i);
             }
          }   
       }
       @LIST=@NEW_LIST;
       @NEW_LIST = ();
    
    }
    if((defined($low_toughness)) && ($low_toughness =~ /\d/)){
       my @NEW_LIST;
    
       for my $i (@LIST){
          if(&valid_numeric($DATABASE[$i][$toughness_i])){
             my $tough = $DATABASE[$i][$toughness_i];
             if($tough =~ /\*/){
                push(@NEW_LIST,$i);
             } elsif ($tough >= $low_toughness){
                push(@NEW_LIST,$i);
             }
          }
       }
       @LIST=@NEW_LIST;
       @NEW_LIST = ();
    }
    return @LIST;

}

##################################################################################
sub valid_numeric{
   my ($what) = @_;
   
   if(defined($what)){
       if($what =~ /\d/){
          return 1;
       }
   }
   return 0;
    


}
##################################################################################
sub filter_on_allowed_color{
   my (@LIST) = @_;
   my @CHECK_FOR;
   my $cnt = 0;
   for my $c (0..$#ALLOWED_HAVE){
      if($ALLOWED_HAVE[$c]){
         $cnt++;
      }   
   }
   if($cnt == 0){
      return @LIST;
   }
   
   for my $c (0..$#ALLOWED_HAVE){
      my $color = $COLORS[$c];
      my $letter = $COLOR_M[$c];
      if($ALLOWED_HAVE[$c]){
         push(@CHECK_FOR,$letter);
      }
   } 
   if($#CHECK_FOR == -1){return @LIST;}
   my @NEW_LIST;
   for my $i (@LIST){
      my $colors = $DATABASE[$i][$color_i];
      my $pass = 0;
      for my $check (@CHECK_FOR){
         if($colors =~ /$check/){
             $pass =1;
         }
      }   
      if($pass){
         push(@NEW_LIST,$i);
      }   
   }
   return @NEW_LIST;
}
##################################################################################
sub filter_on_not_allowed_color{
   my (@LIST) = @_;
   my @CHECK_FOR;
   
   my $cnt = 0;
   for my $c (0..$#NOT_ALLOWED_HAVE){
      if($NOT_ALLOWED_HAVE[$c]){
         $cnt++;
      }   
   }
   if($cnt == 0){
      return @LIST;
   }
   
   for my $c (0..$#NOT_ALLOWED_HAVE){
      my $color = $COLORS[$c];
      my $letter = $COLOR_M[$c];
      if($NOT_ALLOWED_HAVE[$c]){
         push(@CHECK_FOR,$letter);
      }
   } 
   if($#CHECK_FOR == -1){return @LIST;}
   my @NEW_LIST;
   for my $i (@LIST){
      my $colors = $DATABASE[$i][$color_i];
      my $pass = 1;
      for my $check (@CHECK_FOR){
         if($colors =~ /$check/){
             $pass =0;
         }
      }   
      if($pass){
         push(@NEW_LIST,$i);
      }   
   }
   return @NEW_LIST;
}



##################################################################################
sub filter_on_must_color{
   my (@LIST) = @_;
   my @CHECK_FOR;
   for my $c (0..$#MUST_HAVE){
      my $color = $COLORS[$c];
      my $letter = $COLOR_M[$c];
      if($MUST_HAVE[$c]){
         push(@CHECK_FOR,$letter);
      }
   } 
   if($#CHECK_FOR == -1){return @LIST;}
   my @NEW_LIST;
   for my $i (@LIST){
      my $colors = $DATABASE[$i][$color_i];
      my $fail = 0;
      for my $check (@CHECK_FOR){
         if($colors !~ /$check/){
             $fail =1;
         }
      }   
      if($fail == 0){
         push(@NEW_LIST,$i);
      }   
   }
   return @NEW_LIST;
}

##################################################################################
sub get_setname{
   my ($set_code) = @_;

   my @NEW_LIST;
   my @SET_CODES;
   for my $i (0..$#THE_SETS){
      if($THE_SETS[$i][$setcode_i] eq $set_code){
         return $THE_SETS[$i][$setname_i];
      }
   }
   return "Fuck if i know";   
} 
##################################################################################
sub filter_on_rarity{
   my (@LIST) =@_;
   if(($special) && ($mythic) && ($rare) && ($uncommon) && ($common)){
      return @LIST;
   }  
   my @NEW_LIST;
   for my $i (@LIST){
      my $level = $DATABASE[$i][$rarity_i];
      if(($mythic) && ($level =~ /mythic/)){
         push(@NEW_LIST,$i);
      } elsif(($special) && ($level eq "special")){
         push(@NEW_LIST,$i);
      } elsif(($rare) && ($level =~ /rare/)){
         push(@NEW_LIST,$i);
      } elsif(($uncommon) && ($level =~ /uncommon/)){
         push(@NEW_LIST,$i);
      } elsif(($common) && ($level eq "common")){
         push(@NEW_LIST,$i);
      }
   }
   return @NEW_LIST;


}  

##################################################################################
sub filter_on_sets{
   my ($filter,@LIST) = @_;
   if((!defined($filter)) || ($filter !~ /\w/)){
      return @LIST;
   }
      
   my @NEW_LIST;
   my @SET_CODES;
   for my $i (0..$#THE_SETS){
      if($THE_SETS[$i][$setname_i] =~ /$filter/i){
         push(@SET_CODES,$THE_SETS[$i][$setcode_i]);
      } 
   }
   
   for my $i (@LIST){
      my $keep = 0;
      my $this_set_of_codes = $DATABASE[$i][$set_i];
      for my $code (@SET_CODES){
         if($this_set_of_codes =~ /$code/){
            $keep = 1;
         }
      }
      if($keep){
         push(@NEW_LIST,$i);
      } else {
         print DROPPED "$DATABASE[$i][$name_i] set\n";
      }
   }
   
   return @NEW_LIST;

}

##################################################################################
sub is_legal{
   my $good = 0;
   my ($i) = @_;
   my $uuid = $DATABASE[$i][$uuid_i];
   for my $j (@last_legal_sets){
      if($legality_selected_1 ne $last_legal_sets[$j]){
         for my $col (0..$#{$LEGALS[0]}){
            if($LEGALS[0][$col] eq $legality_selected_1){
               $selected_legality_i = $col;
	       $good+=1;
            }
         }   
      push(@last_legal_sets, $legality_selected_1);
   
   }
   
      if($legality_selected_2 ne $last_legal_sets[$j]){
         for my $col (0..$#{$LEGALS[0]}){
            if($LEGALS[0][$col] eq $legality_selected_2){
               $selected_legality_i = $col;
	       $good+=1;
            }
         }   
          push(@last_legal_sets, $legality_selected_2);
      }
   
      if($legality_selected_3 ne $last_legal_sets[$j]){
         for my $col (0..$#{$LEGALS[0]}){
            if($LEGALS[0][$col] eq $legality_selected_3){
               $selected_legality_i = $col;
	       $good+=1;
            }
         }   
         push(@last_legal_sets, $legality_selected_3);;
      }

      if($not_hashed){
         for my $k (1..$#LEGALS){
            $LEGAL_HASH{$LEGALS[$k][$uuid_leg_i]} = $k;
         }
         $not_hashed = 0;
      }
      
      splice(@last_legal_sets, 0, 3);
      my $l = $LEGAL_HASH{$uuid};
      if($LEGALS[$l][$selected_legality_i] eq "Legal") && ($good eq 3){
         return 1;
      } else {
         return 0;
      }
      return 0;
   }
}   


##################################################################################
sub filter_on_legal{
   my (@LIST) = @_;
   my @NEW_LIST;
   
   for my $i (@LIST){
      if(&is_legal($i)){
         push(@NEW_LIST,$i);
      }
   }  
   
   
   return @NEW_LIST;
   
   
   #if($commander_legality){
   #   my @NEW_LIST;
   #   for my $i (@LIST){
   #      my $uuid = $DATABASE[$i][$uuid_i];
   #      my $legal = $LEGAL_HASH{$uuid};
   #      if($legal eq "Legal"){
   #         my $funny = $DATABASE[$i][$funny_i];
   #         if($funny ne "True"){
   #            push(@NEW_LIST,$i);
   #         } else {
   #            print DROPPED "Dropped for funny! : $DATABASE[$i][$name_i]\n";
   #         }
   #      } else {
   #         print DROPPED "not legal $DATABASE[$i][$name_i] legal\n";
   #      }
   #   } 
   #   return @NEW_LIST;
   #} elsif($standard_legality){
   #   my @NEW_LIST;
   #   for my $i (@LIST){
   #      my $uuid = $DATABASE[$i][$uuid_i];
   #      my $legal = $LEGAL_HASH{$uuid}; ##//
   #      if($legal eq "Legal"){
   #         my $funny = $DATABASE[$i][$funny_i];
   #         if($funny ne "True"){
   #            push(@NEW_LIST,$i);
   #         } else {
   #            print DROPPED "Dropped for funny! : $DATABASE[$i][$name_i]\n";
   #         }
   #      } else {
   #         print DROPPED "not legal $DATABASE[$i][$name_i] legal\n";
   #      }
   #   } 
   #   return @NEW_LIST;   
   #
   #   
   #} else {
   #   return @LIST;
   #}
}
##################################################################################
sub filter_on_avail{
   my @LIST = @_;
   my @NEW_LIST = ();
   for my $i (@LIST){
      if($DATABASE[$i][$avail_i] =~ /paper/i){
          push(@NEW_LIST,$i);
      }
   }
   @LIST = @NEW_LIST;
   @NEW_LIST = ();
   
   for my $i (@LIST){
      if($DATABASE[$i][$border_i] !~ /silver/i){
          push(@NEW_LIST,$i);
      }
   }
   
   #@LIST = @NEW_LIST;
   #@NEW_LIST = ();
   #for my $i (@LIST){
   #   if($DATABASE[$i][$border_i] !~ /borderless/i){
   #       push(@NEW_LIST,$i);
   #   } else {
   #      print "borderless:$DATABASE[$i][$name_i]\n";
   #   }
   #}
   
   
   
   
   
   
   
   @LIST = @NEW_LIST;
   @NEW_LIST = ();
   
   for my $i (@LIST){
      if($DATABASE[$i][$promotypes_i] !~ /playtest/i){
          push(@NEW_LIST,$i);
      }
   }
   
   @LIST = @NEW_LIST;
   @NEW_LIST = ();
   
   for my $i (@LIST){
      if($DATABASE[$i][$layout_i] !~ /planar/i){
          push(@NEW_LIST,$i);
      }
   }
   
   
   
   ## layout 45 -> planar
   
   return @NEW_LIST;

}
##################################################################################
sub filter_on_name{
   my ($filt,@LIST) = @_;
   if(!defined($filt)){return @LIST;}
   
   if($filt !~ /\w/){return @LIST;}
   my @NEW_LIST = ();
   for my $i (@LIST){
      if($DATABASE[$i][$name_i] =~ /$filt/i){
          push(@NEW_LIST,$i);
      } else {
         print DROPPED "$DATABASE[$i][$name_i] name\n";
      }
   }
   return @NEW_LIST;
}

##################################################################################
##sub filter_on_set{
##   my ($filt,@LIST) = @_;
##   if($filt eq ""){return @LIST;}
##   my @NEW_LIST = ();
##   for my $i (@LIST){
##      if($DATABASE[$i][$name_i] =~ /$filt/i){
##          push(@NEW_LIST,$i);
##      }
##   }
##   return @NEW_LIST;
##
##
##}

##################################################################################
sub init{

   open(FAILED_TO_DOWNLOAD,"download_fails.txt");
   while(<FAILED_TO_DOWNLOAD>){
      my $line = $_;
      chomp($line);
      push(@FAILS,$line);
   }
   close(FAILED_TO_DOWNLOAD);
   open(FAILED_TO_DOWNLOAD,">>download_fails.txt");



   print "reading sets\n";
   open(SETS,"sets.csv") or die();
   my $in_quotes = 0;
   my $chunk = "";
   my $next_i = 0;
   my $nice = 0;

   
   while(<SETS>){
      my $line = $_;
      my $in_quotes = 0;
      my $l = length($line);
      my @LIST;
      my $i = 0;
      if($nice++%100){
         $mw->update();
      }
      while($i <= $l){
         my $this = substr($line,$i,1);
         if($this eq ","){
            if($in_quotes == 0){
               push(@LIST,$chunk);
               $chunk = "";
            } else {
               $chunk .= $this;
            }
         } elsif($this eq '"'){
            if($in_quotes == 0){
                $in_quotes = 1;
            } else {
               my $next = substr($line,$i+1,1);
               if($next eq '"'){
                  $chunk .= $this;
                  $i++;
               } else {
                  $in_quotes = 0; 
               }
            }
         } else {
           $chunk .= $this;
         }
         $i++;
      }
      push(@LIST,$chunk);
      @{$THE_SETS[$next_i]} = @LIST; 
      $next_i++;

      if($in_quotes){die;}
   } 
   $setcode_i = &find_col("code",@{$THE_SETS[0]});
   $setname_i = &find_col("name",@{$THE_SETS[0]});

   print "Reading database\n";
   open(CARDS,"cards.csv") or die();
   $in_quotes = 0;
   $chunk = "";
   $next_i = 0;
   

   while(<CARDS>){
      my $line = $_;
      my $in_quotes = 0;
      my $l = length($line);
      my @LIST;
      my $i = 0;
      if($nice++%100){
         $mw->update();
      }
      while($i <= $l){
         my $this = substr($line,$i,1);
         if($this eq ","){
            if($in_quotes == 0){
               push(@LIST,$chunk);
               $chunk = "";
            } else {
               $chunk .= $this;
            }
         } elsif($this eq '"'){
            if($in_quotes == 0){
                $in_quotes = 1;
            } else {
               my $next = substr($line,$i+1,1);
               if($next eq '"'){
                  $chunk .= $this;
                  $i++;
               } else {
                  $in_quotes = 0; 
               }
            }
         } else {
           $chunk .= $this;
         }
         $i++;
      }
      push(@LIST,$chunk);
      @{$DATABASE[$next_i]} = @LIST; 
      $next_i++;

      if($in_quotes){die;}
   } 
   print "done reading\n";
   
   $name_i       = &find_col("name",@{$DATABASE[0]});
   $asci_name_i  = &find_col("asciiName",@{$DATABASE[0]});
   $fname_i      = &find_col("faceName",@{$DATABASE[0]});
   $flavorname_i = &find_col("faceFlavorName",@{$DATABASE[0]});
   $set_i        = &find_col("setCode",@{$DATABASE[0]});
   $type_i       = &find_col("type",@{$DATABASE[0]});
   $color_i      = &find_col("colorIdentity",@{$DATABASE[0]});
   $mana_cost_i  = &find_col("manaCost",@{$DATABASE[0]});
   $power_i      = &find_col("power",@{$DATABASE[0]});
   $toughness_i  = &find_col("toughness",@{$DATABASE[0]});
   $text_i       = &find_col("text",@{$DATABASE[0]});

   $keywords_i   = &find_col("keywords",@{$DATABASE[0]});
   $manavalue_i  = &find_col("manaValue",@{$DATABASE[0]});
   $rarity_i     = &find_col("rarity",@{$DATABASE[0]});
   $supertypes_i = &find_col("supertypes",@{$DATABASE[0]});
   $subtypes_i   = &find_col("subtypes",@{$DATABASE[0]});
   $avail_i      = &find_col("availability",@{$DATABASE[0]});
   $border_i     = &find_col("borderColor",@{$DATABASE[0]});
   $funny_i      = &find_col("isFunny",@{$DATABASE[0]});
   
   $flavor_i     = &find_col("flavorText",@{$DATABASE[0]});
   $edhrank_i    = &find_col("edhrecRank",@{$DATABASE[0]});
   $salty_i      = &find_col("edhrecSaltiness",@{$DATABASE[0]});
   
   
   
   $promotypes_i = &find_col("promoTypes",@{$DATABASE[0]});
   $layout_i     = &find_col("layout",@{$DATABASE[0]});
   $oversized_i  = &find_col("isOversized",@{$DATABASE[0]});
   $uuid_i       = &find_col  ("uuid",@{$DATABASE[0]});
   
   open(LEGALITY,"cardLegalities.csv") or die();
   $next_i = 0;
   while(<LEGALITY>){
      my $line = $_;
      my $in_quotes = 0;
      my $l = length($line);
      my @LIST;
      my $i = 0;
      if($nice++%100){
         $mw->update();
      }
      while($i <= $l){
         my $this = substr($line,$i,1);
         if($this eq ","){
            if($in_quotes == 0){
               push(@LIST,$chunk);
               $chunk = "";
            } else {
               $chunk .= $this;
            }
         } elsif($this eq '"'){
            if($in_quotes == 0){
                $in_quotes = 1;
            } else {
               my $next = substr($line,$i+1,1);
               if($next eq '"'){
                  $chunk .= $this;
                  $i++;
               } else {
                  $in_quotes = 0; 
               }
            }
         } else {
           $chunk .= $this;
         }
         $i++;
      }
      push(@LIST,$chunk);
      @{$LEGALS[$next_i]} = @LIST; 
      $next_i++;

      if($in_quotes){die;}
   } 

   $uuid_leg_i    = &find_col  ("uuid",@{$LEGALS[0]});
   my $next = 0;
   #for my $i (0..$#{$LEGALS[0]}){
   #   if($LEGALS[0][$i] ne "uuid"){
   #       $legalities->insert($next,$LEGALS[0][$i]);
   #       $next++;
   #   }
   #}
   
   
   
   ## 

   
   ## cardIdentifiers.csv
   @CARD_IDS = &pull_in_csv("cardIdentifiers.csv");
   
   
   if(0){
      open(OUT,">cleaned.csv") or die();

      ## output cleansed
      for my $i (0..$#DATABASE){
         for my $j (0..$#{$DATABASE[$i]}){
            my $this = $DATABASE[$i][$j];
            if($this =~ /\"/){
               $this =~ s/\"/\"\"/g;
               $this = "\"$this\"";
            }  
            $this =~ s/\n$//g;
            print OUT "$this,";
            if($j == $#{$DATABASE[$i]}){
               print OUT "\n";
            }
         }   
      }
   }
   
   ## hash legals;
   #for my $i (1..$#LEGALS){
   #   my $uuid = $LEGALS[$i][$uuid_leg_i];
   #   for my $j (0..$#{$LEGALS[$i]}){
   #      if($j != $uuid_leg_i){
   #         $LEGAL_HASH{$uuid}=$i;
   #      }
   #   }
   #}    
            
   #   my $uuid  = $LEGALS[$i][$uuid_leg_i];
   #   
   #   
   #   my $legal = $LEGALS[$i][$command_leg_i];
   #   if($legal eq ""){
   #      $legal = "Not Legal";
   #   }
    #  $LEGAL_HASH{$uuid}=$legal;
    #  
    #  $STANDARD_LEGAL_HASH{$uuid]=$LEGALS[$standard_leg_i];;
   #}
   
   open(KW,">keywords.txt");
   my %WC;
   ## generate keywords;
   for my $i (0..$#DATABASE){
      my $text = lc($DATABASE[$i][$text_i]);
      $text =~ s/\(.*\)//g;
      $text =~ s/\\n/ /g;
      $text =~ s/\s+/ /g;
      $text =~ s/\,//g;
      $text =~ s/\.//g;
      $text =~ s/\(//g;
      $text =~ s/\)//g;
      
      my @S = split(/\s+/,$text);
      for my $w (@S){
         $WC{$w}++;
      }
   }
   my @SORTED = sort { $WC{$a} <=> $WC{$b} } keys %WC; 
   @SORTED = reverse(@SORTED);
   my $score= 1;
   ## arbitrarily subdivide into 20 scores;
   my $break_point = $#SORTED/20;
   my $to_go = $break_point;
   for my $i (@SORTED){
      if($to_go-- <= 0){
         $score += 3;
         $to_go=$break_point;
      }
      $SCORES{$i} = $score;
      print KW "$i $WC{$i} $score\n";
      
   }
   close(KW);
   
   
   print "Done hashing; I am ready to search!\n";
   $ready =1;
   $status = "raedy to roll!";
   
   &pick_a_random_card(0);
   
   &init_working();
}

###############################################################################
#sub is_legal_for{
#   my ($uuid,$format) = @_;
#   ## xxxx
#   
#   
#   
#   
#   ## xxxxxxx
#}

###############################################################################

sub get_download_name_for_uuid{
   my ($uuid) = @_;
   
   # scryfallId
   # scryfallCardBackId

   
   if(!defined($card_id_uuid_i)){
      for my $i (0..$#{$CARD_IDS[0]}){
         $CARD_IDS[0][$i] =~ s/^\s*(.*)\s*$/$1/;
         if(lc($CARD_IDS[0][$i]) eq "uuid"){
            $card_id_uuid_i = $i;
         } elsif($CARD_IDS[0][$i] eq "scryfallId"){
            $card_id_scryfallId_i=$i;
         }   
      }
    #  print "Cols = $card_id_uuid_i and $card_id_scryfallId_i\n";
   }   
   
   $uuid =~ s/\s*//g;   
   for my $i (1..$#CARD_IDS){
      my $this = $CARD_IDS[$i][$card_id_uuid_i];
      $this =~ s/\s*//g;
         
      if($this eq $uuid){
         return $CARD_IDS[$i][$card_id_scryfallId_i];
      }
   } 
   
   print "WAS NOT FOUND!!!!!!!!\n";
   return "not found";
}

###############################################################################

sub pull_in_csv{
   my ($file) = @_;
   open(CSV_FILE,$file) or die();
   my $next_i = 0;
   my $nice = 0;
   my $chunk = "";
   my @OUTPUT;
   while(<CSV_FILE>){
      my $line = $_;
      my $in_quotes = 0;
      my $l = length($line);
      my @LIST;
      my $i = 0;
      if($nice++%100){
         $mw->update();
      }
      while($i <= $l){
         my $this = substr($line,$i,1);
         if($this eq ","){
            if($in_quotes == 0){
               push(@LIST,$chunk);
               $chunk = "";
            } else {
               $chunk .= $this;
            }
         } elsif($this eq '"'){
            if($in_quotes == 0){
                $in_quotes = 1;
            } else {
               my $next = substr($line,$i+1,1);
               if($next eq '"'){
                  $chunk .= $this;
                  $i++;
               } else {
                  $in_quotes = 0; 
               }
            }
         } else {
           $chunk .= $this;
         }
         $i++;
      }
      push(@LIST,$chunk);
      @{$OUTPUT[$next_i]} = @LIST; 
      $next_i++;

      if($in_quotes){die;}
   } 
   close(CSV_FILE);
   return @OUTPUT;


}

##################################################################################
sub clip_dups{
   my (@LIST) = @_;
   my %H;
   my @NEW_LIST;
   for my $i (@LIST){
      my $name = $DATABASE[$i][$name_i];
      my $fname = $DATABASE[$i][$fname_i];
      my $use = $name.":".$fname;
      if(!defined($H{$use})){
         push(@NEW_LIST,$i);
         $H{$use}=1;
      }
   } 
   return @NEW_LIST;
}

##################################################################################
sub dump_list{
   my (@THE_LIST) = @_;
   print "Dumping list\n";
   
   open(OUT,">out.txt") or die();
   for my $this (@THE_LIST){
      if($this =~ /(\w)\_(.*)XXX(\d+)/){
         my $cmc = $1;
         my $name = $2;
         my $i    = $3;   
         print OUT "***************************************\n";
         print OUT "name = $DATABASE[$i][$name_i]\n";
         print OUT "type = $DATABASE[$i][$type_i]\n";
         print OUT "colorIdentity = $DATABASE[$i][$color_i]\n";
         print OUT "manaCost = $DATABASE[$i][$mana_cost_i]\n";
         print OUT "power = $DATABASE[$i][$power_i]\n";
         print OUT "toughness = $DATABASE[$i][$toughness_i]\n";
         print OUT "keywords = $DATABASE[$i][$keywords_i]\n";
         print OUT "manaValue = $DATABASE[$i][$manavalue_i]\n";
         print OUT "rarity = $DATABASE[$i][$rarity_i]\n";
         print OUT "supertypes = $DATABASE[$i][$supertypes_i]\n";
         my $uuid = $DATABASE[$i][$uuid_i];
         #my $legal = $LEGAL_HASH{$uuid};
         #print OUT "LEGAL = $legal\n";

         print OUT "SETCODE = $DATABASE[$i][$set_i]\n";
         my $actual = &get_setname($DATABASE[$i][$set_i]);
         print OUT "SET ENGLISH NAME = $actual\n";
         my $t = $DATABASE[$i][$text_i];
         $t =~ s/\\n/\n/g;
         print OUT "text = $t\n";
      }
   }
   close(OUT);
   open(OUT,">dbg.txt") or die();
   
   for my $this (@THE_LIST){
      if($this =~ /(\w)\_(.*)XXX(\d+)/){
         my $cmc = $1;
         my $name = $2;
         my $i    = $3;   
         print OUT "***************************************\n";
         print OUT "name = $DATABASE[$i][$name_i]\n";
         for my $z (0..$#{$DATABASE[0]}){
            print OUT "$DATABASE[0][$z] $z -> $DATABASE[$i][$z]\n";
         }
      }
   }
   close(OUT);
}

##################################################################################

sub find_col{
   my ($what,@COLS) = @_;
   for my $col (0..$#COLS){
      if($COLS[$col] eq $what){ 
          return $col;
      }
   }
   print "$what not found!\n";
   die();
   
   
   
}
##################################################################################
## use cygwin's wget
sub do_html_stuff{
   my ($page) = @_;
   my $dk = `C:\\cygwin64\\bin\\wget.exe -O me.html \"$page\" > html.out 2>&1`;
   
   `$dk`;
   
   my $text = "";
   open(HTML,"me.html");
   while(<HTML>){
      my $line = $_;
      $text .= $line;
   }
   close(HTML);
   return $text;
   
   
   
}   
##################################################################################
##################################################################################
## xxx
sub get_art_and_display{
         
 #  Front: https://cards.scryfall.io/large/front/6/7/67f4c93b-080c-4196-b095-6a120a221988.jpg
 #  Back: https://cards.scryfall.io/large/back/6/7/67f4c93b-080c-4196-b095-6a120a221988.jpg

   
   
   ## THIS IS WHERE I AM!!!  
   ## Front: https://cards.scryfall.io/large/front/6/7/67f4c93b-080c-4196-b095-6a120a221988.jpg
   
   
   my $side;
   if($get_front){
      $side = "front";
   } else {
      $side = "back";
   }
   my $dir1 = substr($get_this_thing,0,1);
   my $dir2 = substr($get_this_thing,1,1);
   
   
   my $get = "https:\/\/cards.scryfall.io/large/$side/".$dir1."/".$dir2."/$get_this_thing\.jpg";
   print "Get = $get\n";
   print "name = $ascii_name\n";
   
   my $response   = $ua->get($get,':content_file' => "ART2\\".$ascii_name);
   if($response->is_success){
      print "resonse is good\n";
   } else {
      print "resonse is bad\n";
   }

   my $orig_image = $mw->Photo('-format' => 'jpeg', -file => "ART2\\".$ascii_name);

   my $max_x = 672;
   my $max_y = 936;   
   my $mod = 2;

   my @NEW;
   for my $x (0..$max_x/$mod-1){
      for my $y (0..$max_y/$mod-1){
         if($turn_right){
            my $target_x = $x*$mod;
            my $target_y = $y*$mod;

            my @P = $orig_image->get($target_x,$target_y+($mod/2));
            my $load_y=($max_y/$mod)-$y;
            $NEW[$x][$load_y]=sprintf("#%02x%02x%02x",@P);

         } else {
            my $target_x = $x*$mod;
            my $target_y = $y*$mod;

            my @P = $orig_image->get($target_x,$target_y+($mod/2));
            $NEW[$y][$x]=sprintf("#%02x%02x%02x",@P);
         }   
      }
   } 
   ## i am not sure why; i need this; but some are not defined?
   for my $x (0..$#NEW){
      for my $y (0..$#{$NEW[$x]}){
         if($NEW[$x][$y] !~ /\#/){
             $NEW[$x][$y] = "#000000";
         }
      }
   }

   my $image=$mw->Photo();

   $image->blank;
   $image->put(\@NEW,-to=>0,0);
   $image_lbl->configure(-image=>$image);
   $image_lbl->pack;

   $old_image1 =$image;
   $old_image2 = $orig_image;

}

sub failed_to_download{
   my ($what)=@_;
   
   for my $failed (@FAILS){
      if($what eq $failed){
         return 1;
      }
   }
   return 0;


}

sub pick_a_random_card2{
   my ($jank) = @_;
   my $not_done = 1;
   while($not_done){
      my $i = int(rand() * $#DATABASE);
      print "********************************************\n";
      print "Random is picking i = $i $DATABASE[$i][$name_i]\n";
      my $reject = 0;
      
      if($jank){
          my $edhrank= $DATABASE[$i][$edhrank_i];
          if($edhrank < $jank_edh_rank){
             $reject = 1;
          }   
      } 
      if((&is_legal($i)) && ($reject == 0)){
         $hlist->delete('all');
         my $display_string = &build_string_for($i);
         @MAP=();
         $MAP[$i] = $i;
         $hlist->add(0 ,-text=>$display_string);
         &hlist_select_call($i) ;
         $not_done = 0;
      } else {
         print " is not legal or not jank\n";
      }
   }   

}
   
sub pick_a_random_card{
   my ($jank) = @_;
   my $not_done = 1;
   while($not_done){
      my @LIST;
      for my $i (1..$#DATABASE){
         push(@LIST,$i);
      }       
      @LIST = &filter_on_legal(@LIST);
      @LIST = &filter_on_sets($set_filter,@LIST);
    #  @LIST = &weight_by_jank(@LIST);
   
      my $reject = 0;
      
      my $i = int($#LIST*rand());
      $i = $LIST[$i];
      
      
      if($jank){
          my $edhrank= $DATABASE[$i][$edhrank_i];
          if($edhrank < $jank_edh_rank){
             $reject = 1;
          }   
      } 
      if((&is_legal($i)) && ($reject == 0)){
         $hlist->delete('all');
         my $display_string = &build_string_for($i);
         @MAP=();
         $MAP[0] = $i;
         $hlist->add(0 ,-text=>$display_string);
         &hlist_select_call(0) ;
         $not_done = 0;
      } else {
         print " is not legal or not jank\n";
      }
   }   
}
 
sub weight_by_jank{
    my (@LIST) = @_;
    
    if(!defined($worst)){
       @NEW = ();
       for my $i (@LIST){
          my $rank = $DATABASE[$i][$edhrank_i];
          if($rank > $worst){
              $worst=$rank;
          }
       }    
       ## jank_edh_rank
       ## generate a weighted list;
       ## 3-5 entries per card;
       my $break_one = $jank_edh_rank;
       my $distance = $worst-$break_one;
       my $sub_distance = $distance / 3;
       my $break_two   = $break_one+$sub_distance;
       my $break_three = $break_one+2*$sub_distance;

       for my $i (@LIST){
          my $rank = $DATABASE[$i][$edhrank_i];
          
          if($rank < $jank_edh_rank){
             ## we dont' want it
          } elsif ($rank < $break_one){
              push(@NEW,$i);
              push(@NEW,$i);
          } elsif($rank < $break_two){
              push(@NEW,$i);
              push(@NEW,$i);
              push(@NEW,$i);
          } else {
              push(@NEW,$i);
              push(@NEW,$i);
              push(@NEW,$i);
              push(@NEW,$i);
              push(@NEW,$i);
          }
      }
   }
   return @NEW;
}

   
   
   