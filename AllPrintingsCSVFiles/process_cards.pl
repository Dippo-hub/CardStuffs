#!usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw(time);
use POSIX qw(strftime);

use Tk;
use LWP::Simple;
use LWP::UserAgent;
use Tk::JPEG;
use Text::CSV;
use open qw(:std :encoding(UTF-8)); 
require Tk::HList;
require Tk::ROText;

open(DBG,">debug.txt");

my $pwd = `cd`;
chomp($pwd);

## to pull in new cards :  goto : https://mtgjson.com/downloads/all-files/#allprintings
## download AllPrintingsCSVFiles
## unzip in same dir as this script

my @SORT_BY = ("CMC","EDH Rank","Salty","Price");

my %TIME_DATA_N;
my %TIME_DATA_DT;
my %TIME_REF;

my %DOWNLOAD_H;

my $similair_uuid;
my $last_was;
my @CURRENT_SEARCH;


########################################################################################
## ui state variables: all these need to get hit by clear
my $eliminate_dups = 1;
my $legality_selected = "commander";
my $name_filter = "";
my $set_filter  = "";
my $english = 1;
my $mythic =1;
my $rare =1;
my $uncommon =1;
my $common =1;
my $special = 1;
my @MUST_HAVE;
my @ALLOWED_HAVE;
my @NOT_ALLOWED_HAVE;
my $high_power = "";
my $low_power = "";
my $high_toughness = "";
my $low_toughness = "";
my $low = "";
my $high = "";
my $subtype = "";
my $super_type = "";
my @ALLOWED_TYPES;
my @NOT_ALLOWED_TYPES;
my $text1 = "";
my $text2 = "";
my $text3 = "";
my $text4 = "";
my $text5 = "";
my $text6 = "";
my $text7 = "";
my $text8 = "";
my @OR_TEXT = ("","","","");
my $ntext1 = "";
my $ntext2 = "";
my $ntext3 = "";
my $ntext4 = "";
my $sort_by = $SORT_BY[0];

###############################################################################

my %HRULES;
my %HLONG;

my $get_this_thing;
my $next_art = -1;
my $display_art = 1;
my $display_text_box = 0;

my @FAILS;
my @NEW;
my %SCORES;

my $worst;
my $starting;

my $viewer_top;
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
my $ready = 0;

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
my $language_i;


my @THE_SETS;
my $setcode_i;
my $setname_i;


my @PRICES;
my $price_uuid_i;
my $price_price_i;
my $price_price_provider;
my $price_currency_i;
my $price_listing_i;

my %PRICE_HASH;
my @CHEAPEST_LIST;




my %LEGAL_HASH;
my $not_hashed = 1;
my @LEGALS;
my $uuid_leg_i;
my $selected_legality_i;
my $last_legal_set = "";



my @RULINGS;
my $ruling_uuid_i;
my $ruling_text_i;

my @CARD_IDS;
my $card_id_uuid_i;
my $card_id_scryfallId_i;



my $mw = new MainWindow;
$mw->setPalette('#444444');  ##"#FFDEAD");
$mw->configure(-title=>'MTG!');
my $mbar = $mw->Menu();
$mw->configure(-menu => $mbar);

my $file = $mbar -> cascade(-label=>"File", -underline=>0, -tearoff => 0);
$file->checkbutton(-label =>"Open",-command => [\&commands, "Open"]);
$file -> command(-label =>"Save",-command => [\&commands, "Save"]);

my @ENTRIES;
my @FIELDS;
my @ENABLES;

my @COLORS=("White","Blue","Green","Red","Black");
my @COLOR_M=("W","U","G","R","B");
my @TYPES = ("Artifact","Battle","Creature","Enchantment","Instant","Land","legendary","Planeswalker","Sorcery","kindred");
for my $z (0..$#TYPES){
   $ALLOWED_TYPES[$z]=0;
   $NOT_ALLOWED_TYPES[$z]=0;
}


my $label;
my $entry;
my $spacer;

my $top_frame     =$mw->Frame()->pack(-side=>'top');
my $bottom_frame  =$mw->Frame()->pack(-side=>'top');
my $bottom_frame2 =$mw->Frame(-borderwidth=>2,-relief=>'ridge')->pack(-side=>'top');



my $left_frame   = $top_frame->Frame()->pack(-side=>'left');
my $right_frame  = $top_frame->Frame()->pack(-side=>'left');
my $right_frameB = $top_frame->Frame()->pack(-side=>'left');

my $right_frame2 = $top_frame->Frame()->pack(-side=>'left');
my $right_frame3 = $top_frame->Frame()->pack(-side=>'left');

#############################################################################################
## legal sets;

my $frame      = $left_frame->Frame()->pack(-side=>'top');

my @LEGAL_CHOICES = qw(dont_care alchemy brawl commander duel future gladiator 
                       historic legacy modern oathbreaker oldschool 
                       pauper paupercommander penny pioneer predh 
                       premodern standard standardbrawl timeless vintage);
my $legal_lble = $frame->Label(-text=>"Format",-width=>6)->pack(-side=>'left');                       
my $legalities = $frame->Optionmenu(-options=>\@LEGAL_CHOICES,-textvariable=>\$legality_selected,-width=>42)->pack(-side=>'left');
&splitter();

#############################################################################################
## name   
   $frame      = $left_frame->Frame()->pack(-side=>'top');
my $name       = $frame->Label(-text=>"Name",-width=>6)->pack(-side=>'left');
my $name_entry = $frame->Entry(-textvariable=>\$name_filter,-width=>49)->pack(-side=>'left');

#############################################################################################
## set
$frame          = $left_frame->Frame()->pack(-side=>'top');
my $set         = $frame->Label(-text=>"Set",-width=>6)->pack(-side=>'left');
my $set_entry   = $frame->Entry(-textvariable=>\$set_filter,-width=>49)->pack(-side=>'left');

#############################################################################################
## dups
$frame      = $left_frame->Frame()->pack(-side=>'top');
my $dups = $frame->Checkbutton(-text=>"No dups",-variable=>\$eliminate_dups)->pack(-anchor => 'w',-side=>'left');

my $lang = $frame->Checkbutton(-text=>"Eng Only",-variable=>\$english)->pack(-anchor => 'w',-side=>'left');


my $specs   = $frame->Checkbutton(-text=>"S",-variable=>\$special)->pack(-anchor => 'w',-side=>'left');
my $mythics = $frame->Checkbutton(-text=>"M",-variable=>\$mythic)->pack(-anchor => 'w',-side=>'left');
my $rares = $frame->Checkbutton(-text=>"R",-variable=>\$rare)->pack(-anchor => 'w',-side=>'left');
my $uncommons = $frame->Checkbutton(-text=>"U",-variable=>\$uncommon)->pack(-anchor => 'w',-side=>'left');
my $commons = $frame->Checkbutton(-text=>"C",-variable=>\$common)->pack(-anchor => 'w',-side=>'left');

&splitter();

#############################################################################################
## color  (must have)

$frame      = $left_frame->Frame()->pack(-side=>'top');
$label = $frame->Label(-text=>"Must BE       :")->pack(-side=>'left');
for my $i (0..$#COLORS){
   my $name = $COLORS[$i];
   my $f1 = $frame->Checkbutton(-text=>$name,-variable=>\$MUST_HAVE[$i])->pack(-anchor => 'w',-side=>'left');
   $MUST_HAVE[$i]=0;
} 
my $space = $frame->Label(-text=>":",-width=>1)->pack(-side=>'left');


#############################################################################################
## color  (allowed to have)

$frame      = $left_frame->Frame()->pack(-side=>'top');
$label = $frame->Label(-text=>"Allowed to be:")->pack(-side=>'left');

for my $i (0..$#COLORS){
   my $name = $COLORS[$i];
   my $f1 = $frame->Checkbutton(-text=>$name,-variable=>\$ALLOWED_HAVE[$i])->pack(-anchor => 'w',-side=>'left');
   $ALLOWED_HAVE[$i]=0;
} 
$space = $frame->Label(-text=>":",-width=>1)->pack(-side=>'left');

#############################################################################################
## color  (CANT have)

$frame      = $left_frame->Frame()->pack(-side=>'top');
$label = $frame->Label(-text=>"Not Allowed: ")->pack(-side=>'left');

for my $i (0..$#COLORS){
   my $name = $COLORS[$i];
   my $f1 = $frame->Checkbutton(-text=>$name,-variable=>\$NOT_ALLOWED_HAVE[$i])->pack(-anchor => 'w',-side=>'left');
   $NOT_ALLOWED_HAVE[$i]=0;
} 
$space = $frame->Label(-text=>":",-width=>1)->pack(-side=>'left');

&splitter();

#############################################################################################
$frame = $left_frame->Frame()->pack(-side=>'top');
$label = $frame->Label(-text=>"Power:")->pack(-side=>'left');
$entry = $frame->Entry(-textvariable=>\$low_power,-width=>5)->pack(-side=>'left');
$name  = $frame->Label(-text=>"to:")->pack(-side=>'left');
$entry = $frame->Entry(-textvariable=>\$high_power,-width=>5)->pack(-side=>'left');

#############################################################################################
$label = $frame->Label(-text=>"Toughness:")->pack(-side=>'left');
$entry = $frame->Entry(-textvariable=>\$low_toughness,-width=>5)->pack(-side=>'left');
$name  = $frame->Label(-text=>"to")->pack(-side=>'left');
$entry = $frame->Entry(-textvariable=>\$high_toughness,-width=>5)->pack(-side=>'left');
$space = $frame->Label(-text=>":",-width=>10)->pack(-side=>'left');
&splitter();


#############################################################################################
## cost
$frame  = $left_frame->Frame()->pack(-side=>'top');
$label  = $frame->Label(-text=>"Converted mana cost:  ")->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$low,-width=>5)->pack(-side=>'left');
$label  = $frame->Label(-text=>" to ")->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$high,-width=>5)->pack(-side=>'left');
$space  = $frame->Label(-text=>"       ",-width=>18)->pack(-side=>'left');
&splitter();

#############################################################################################
## sub types  /  super types;

$frame = $left_frame->Frame()->pack(-side=>'top');
$label  = $frame->Label(-text=>"subtype:")->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$subtype,-width=>10)->pack(-side=>'left');

$label  = $frame->Label(-text=>"super type:")->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$super_type,-width=>10)->pack(-side=>'left');
$space  = $frame->Label(-text=>"       ",-width=>10)->pack(-side=>'left');

&splitter();
#############################################################################################

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


$frame  = $left_frame->Frame()->pack(-side=>'top');
$label  = $frame->Label(-text=>"TEXT ORS:")->pack(-side=>'left');
$frame  = $left_frame->Frame()->pack(-side=>'top');

$entry  = $frame->Entry(-textvariable=>\$OR_TEXT[0],-width=>10)->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$OR_TEXT[1],-width=>10)->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$OR_TEXT[2],-width=>10)->pack(-side=>'left');
$entry  = $frame->Entry(-textvariable=>\$OR_TEXT[3],-width=>10)->pack(-side=>'left');
$OR_TEXT[0]="";
$OR_TEXT[1]="";
$OR_TEXT[2]="";
$OR_TEXT[3]="";

#############################################################################################
## not text

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
my $search_found = "";

my $jank_edh_rank = 15000;

my $next_frame=$left_frame->Frame()->pack(-side=>'top');
$next_frame=$next_frame->Frame()->pack(-side=>'top');
my $button=$next_frame->Button(-text=>"Search",-command=>[\&commands, "search"],-width=>24)->pack(-side=>'left');
   $button=$next_frame->Button(-text=>"Clear",-command=>[\&commands, "Clear"],-width=>24)->pack(-side=>'left');

$next_frame=$left_frame->Frame()->pack(-side=>'top');

   $button=$next_frame->Button(-text=>"Random",-command=>[\&commands, "random"])->pack(-side=>'left');
   $button=$next_frame->Button(-text=>"Jank",-command=>[\&commands, "random jank"])->pack(-side=>'left');
   $button=$next_frame->Button(-text=>"Neighbors",-command=>[\&commands, "find_sim"])->pack(-side=>'left');
   $button=$next_frame->Button(-text=>"Add",-command=>[\&commands, "add to list"])->pack(-side=>'left');
   $button=$next_frame->Button(-text=>"Remove",-command=>[\&commands, "remove to list"])->pack(-side=>'left');
   $button=$next_frame->Button(-text=>"download",-command=>[\&commands, "download"])->pack(-side=>'left');
   $button=$next_frame->Button(-text=>"Write",-command=>[\&commands, "write out search"])->pack(-side=>'left');
      

my $image_lbl = $right_frame3->Label()->pack(-side=>'top');
my $flip_button = $right_frame3->Button(-text=>'flip',-command=>[\&commands, "flip"],-width=>25)->pack(-side=>'left');
my $rotate_right = $right_frame3->Button(-text=>'Rot right',-command=>[\&commands, "right_turn"],-width=>25)->pack(-side=>'left');


my $note_width=205;
my $note_width_in_chars = 205; #300;
my $notes1;
my $notes2;
my $notes3;

my $stat   = $bottom_frame->Label(-textvariable=>\$status)->pack(-side=>'left');
my $notesa = $bottom_frame->Label(-textvariable=>\$notes1,-width=>40)->pack(-side=>'left');
my $notesb = $bottom_frame->Label(-textvariable=>\$notes2,-width=>40)->pack(-side=>'left');
my $notesc = $bottom_frame->Label(-textvariable=>\$notes3)->pack(-side=>'left');

my $scrollbar_rules   = $bottom_frame2->Scrollbar( );
my $rulings = $bottom_frame2->ROText(
            -height=>10,
            -width=>205,
            -font=>'courier 8',
            -yscrollcommand => [set => $scrollbar_rules])->pack(-side=>'top');
            
$scrollbar_rules->configure(-command => ['yview' => $rulings]);
$scrollbar_rules->pack(-side => 'right', -fill => 'y');
$rulings->pack(-side => 'left', -fill => 'both');

                                 
                                 

`mkdir ART2 > NUL 2>&1`;

$mw->bind('<Key>' => \&key_hit);     



$mw->after(1000,\&init);
MainLoop;

###############################################################################
sub clear_dialogs{
   $eliminate_dups = 1;
   $legality_selected = "commander";
   $name_filter = "";
   $set_filter  = "";
   $english = 1;
   $mythic =1;
   $rare =1;
   $uncommon =1;
   $common =1;
   $special = 1;
   $high_power = "";
   $low_power = "";
   $high_toughness = "";
   $low_toughness = "";
   $low = "";
   $high = "";
   $subtype = "";
   $super_type = "";
   for my $i (0..$#TYPES){
      $ALLOWED_TYPES[$i] = 0;
      $NOT_ALLOWED_TYPES[$i]=0;
   }
   for my $i (0..$#COLORS){
      $MUST_HAVE[$i] = 0;
      $ALLOWED_HAVE[$i] = 0;
      $NOT_ALLOWED_HAVE[$i] = 0;
   }   
   $text1 = "";
   $text2 = "";
   $text3 = "";
   $text4 = "";
   $text5 = "";
   $text6 = "";
   $text7 = "";
   $text8 = "";
   @OR_TEXT = ("","","","");
   $ntext1 = "";
   $ntext2 = "";
   $ntext3 = "";
   $ntext4 = "";
   $sort_by = $SORT_BY[0];
}

##################################################################################
sub key_hit{
   my($widget) = @_; 

   # get reference to X11 event structure
   my $e = $widget->XEvent;
   my($keysym_text, $keysym_decimal) = ($e->K, $e->N);
   
   if($keysym_text eq "Return"){
      &commands("search");
   }
   



}

##################################################################################
sub get_starting_list{
   
   my @LIST;
   if($eliminate_dups){
      @LIST = @CHEAPEST_LIST;
   } else {
      for my $i (1..$#DATABASE){
         if(&is_legal($i)){
            push(@LIST,$i);
         }   
      }
   }
   return @LIST;
}

##################################################################################
sub open_save_search{
   my $file = $mw->getOpenFile(-initialdir=>$pwd);
   if($file ne ""){
      open(FILE,$file);
      while(<FILE>){
         my $line = $_;
         chomp($line);
         if($line =~ /last_search\:(.*)/){
            $last_was=$1;
         } elsif($line =~ /similair_UUID\:(.*)/){
            $similair_uuid = $1;
            $starting = &get_i_for_uuid($similair_uuid);            
         }elsif($line =~ /eliminate_dups\:(.*)/){
            $eliminate_dups = $1;
         } elsif($line =~ /legality_selected\:(.*)/){
            $legality_selected = $1;
         } elsif($line =~ /name_filter\:(.*)/){
            $name_filter = $1;
         } elsif($line =~ /set_filter\:(.*)/){
            $set_filter = $1;
         } elsif($line =~ /english\:(.*)/){
            $english = $1;
         } elsif($line =~ /mythic\:(.*)/){
            $mythic = $1;
         } elsif($line =~ /rare\:(.*)/){
            $rare = $1;
         } elsif($line =~ /uncommon\:(.*)/){
            $uncommon = $1;
         } elsif($line =~ /^common\:(.*)/){
            $common = $1;
         } elsif($line =~ /special\:(.*)/){
            $special = $1;
         } elsif($line =~ /high_power\:(.*)/){
            $high_power = $1;
         } elsif($line =~ /low_power\:(.*)/){
            $low_power = $1;
         } elsif($line =~ /high_toughness\:(.*)/){
            $high_toughness = $1;
         } elsif($line =~ /low_toughness\:(.*)/){
            $low_toughness = $1;
         } elsif($line =~ /^low\:(.*)/){
            $low = $1;
         } elsif($line =~ /^high\:(.*)/){
            $high = $1;
         } elsif($line =~ /^subtype\:(.*)/){
            $subtype = $1;
         } elsif($line =~ /^super_type\:(.*)/){
            $super_type = $1;
         } elsif($line =~ /^text1\:(.*)/){
            $text1 = $1;
         } elsif($line =~ /^text2\:(.*)/){
            $text2 = $1;
         } elsif($line =~ /^text3\:(.*)/){
            $text3 = $1;
         } elsif($line =~ /^text4\:(.*)/){
            $text4 = $1;
         } elsif($line =~ /^text5\:(.*)/){
            $text5 = $1;
         } elsif($line =~ /^text6\:(.*)/){
            $text6 = $1;
         } elsif($line =~ /^text7\:(.*)/){
            $text7 = $1;
         } elsif($line =~ /^text8\:(.*)/){
            $text8 = $1;
         } elsif($line =~ /^ntext1\:(.*)/){
            $ntext1 = $1;
         } elsif($line =~ /^ntext2\:(.*)/){
            $ntext2 = $1;
         } elsif($line =~ /^ntext3\:(.*)/){
            $ntext3 = $1;
         } elsif($line =~ /^ntext4\:(.*)/){
            $ntext4 = $1;
         } elsif($line =~ /^ALLOWED_TYPES\:(.*)\:/){
            @ALLOWED_TYPES=split(/\:/,$1);
         } elsif($line =~ /^NOT_ALLOWED_TYPES\:(.*)\:/){
            @NOT_ALLOWED_TYPES=split(/\:/,$1);
         } elsif($line =~ /^MUST_HAVE_COLORS\:(.*)\:/){
            @MUST_HAVE=split(/\:/,$1);
         } elsif($line =~ /^ALLOWED_HAVE\:(.*)\:/){
            @ALLOWED_HAVE=split(/\:/,$1);
         } elsif($line =~ /^NOT_ALLOWED_HAVE\:(.*)\:/){
            @NOT_ALLOWED_HAVE=split(/\:/,$1);
         } elsif($line =~ /^OR_TEXT\:(.*)\:/){
            @OR_TEXT=split(/\:/,$1);
         }
     }
     &commands($last_was);
            
     close(FILE);
     
   
   }
}

##################################################################################
sub save_current_search{

   my $file = $mw->getSaveFile(-initialdir=>$pwd);
   
   if(defined($file)){

      open(SAVE,">$file");
      
      print SAVE "last_search:$last_was\n";
      print SAVE "similair_UUID:$similair_uuid\n";
      print SAVE "eliminate_dups:$eliminate_dups\n";
      print SAVE "legality_selected:$legality_selected\n";
      print SAVE "name_filter:$name_filter\n";
      print SAVE "set_filter:$set_filter\n";
      print SAVE "english:$english\n";
      print SAVE "mythic:$mythic\n";
      print SAVE "rare:$rare\n";
      print SAVE "uncommon:$uncommon\n";
      print SAVE "common:$common\n";
      print SAVE "special:$special\n";
      print SAVE "high_power:$high_power\n";
      print SAVE "low_power:$low_power\n";
      print SAVE "high_toughness:$high_toughness\n";
      print SAVE "low_toughness:$low_toughness\n";
      print SAVE "low:$low\n";
      print SAVE "high:$high\n";
      print SAVE "subtype:$subtype\n";
      print SAVE "super_type:$super_type\n";   
      print SAVE "text1:$text1\n";
      print SAVE "text2:$text2\n";
      print SAVE "text3:$text3\n";
      print SAVE "text4:$text4\n";
      print SAVE "text5:$text5\n";
      print SAVE "text6:$text6\n";
      print SAVE "text7:$text7\n";
      print SAVE "text8:$text8\n";
      print SAVE "ntext1:$ntext1\n";
      print SAVE "ntext2:$ntext2\n";
      print SAVE "ntext3:$ntext3\n";
      print SAVE "ntext4:$ntext4\n";

      print SAVE "ALLOWED_TYPES:";
      for my $i (0..$#TYPES){
         print SAVE "$ALLOWED_TYPES[$i]:";
      }
      print SAVE "\n";

      print SAVE "NOT_ALLOWED_TYPES:";
      for my $i (0..$#TYPES){
         print SAVE "$NOT_ALLOWED_TYPES[$i]:";
      }
      print SAVE "\n";  

      print SAVE "MUST_HAVE_COLORS:";
      for my $i (0..$#MUST_HAVE){
         print SAVE "$MUST_HAVE[$i]:";
      }
      print SAVE "\n";  

      print SAVE "ALLOWED_HAVE:";
      for my $i (0..$#ALLOWED_HAVE){
         print SAVE "$ALLOWED_HAVE[$i]:";
      }
      print SAVE "\n";  

      print SAVE "NOT_ALLOWED_HAVE:";
      for my $i (0..$#NOT_ALLOWED_HAVE){
         print SAVE "$NOT_ALLOWED_HAVE[$i]:";
      }
      print SAVE "\n";  

      print SAVE "OR_TEXT:";
      for my $i (0..$#OR_TEXT){
         print SAVE $OR_TEXT[$i].":";
      }
      print SAVE "\n";


      close SAVE;
   
   }
}


##################################################################################
sub commands{
   my ($cmd) = @_;
   
   &update_status("$cmd");
   
   if(!$ready){
      print "I am not ready yet!\n";
      return;
   }
   if($cmd eq "Open"){
      &open_save_search();
   
   } elsif($cmd eq "Save"){
      &save_current_search();
   
   } elsif($cmd eq "Clear"){
      &clear_dialogs();      
      $mw->update();
      
   } elsif($cmd eq "find_sim"){
      $last_was = "find_sim";
      &find_similair();
      
   } elsif($cmd eq "add to list"){
      &add_to_working();   
   
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
     
   } elsif($cmd eq "write out search"){
     &output_search_list();
   
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
       
       $last_was = "search";
       &time_log("search","start");
       
       @LIST = &get_starting_list();
              
       $d = $#LIST;
       print "Staring from $d\n";       
       
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
       if($english){
          @LIST = &filter_out_nonenglish(@LIST);
       }
       
       

       print "*****************************************\n";
       $d = $#LIST+1;
       print "Found $d matches\n";
       for my $i (@LIST){
          my $uuid = $DATABASE[$i][$uuid_i];
          my $border = $DATABASE[$i][$border_i];
          my $funny  = $DATABASE[$i][$funny_i];
          print "$i -> $border || $funny || $uuid || $DATABASE[$i][$name_i]\n";
       }
       print "Found $d matches\n";
       
       &update_hlist_with_sort_of(@LIST);
       &time_log("search","stop");
       if($d > 0){
          &hlist_select_call(0);
       } else {
          &display_null();
       }
       @CURRENT_SEARCH=@LIST;
   }
   if($ready){
      &update_status("ready!");
   }
}

sub update_hlist_with_sort_of{
   my (@LIST) = @_;
   
   my $d = $#LIST+1;
   $search_found = $d;
   my @SORTED;
   
   
   if($d > 0){
      my @SORT;
      if($sort_by eq "CMC"){
         ## sort by cmc;
         for my $i (@LIST){
            my $cmc = $DATABASE[$i][$manavalue_i];
            my $sort_name = sprintf("%8i:%i",$cmc,$i);
            push(@SORT,$sort_name);
         }
      } elsif($sort_by eq "EDH Rank"){
         ## sort by edhrank_i;
         for my $i (@LIST){
            my $sort_name = sprintf("%8i:%i",$DATABASE[$i][$edhrank_i],$i);
            push(@SORT,$sort_name);
         }  
      } elsif($sort_by eq "Salty"){
         for my $i (@LIST){
            my $start_from = $DATABASE[$i][$salty_i];
            if($start_from eq ""){
               $start_from = 0;
            }
            my $salt = 1000 - int($start_from*100);
            my $sort_name = sprintf("%8i:%i",$salt,$i);
            push(@SORT,$sort_name);
         }  
      } elsif($sort_by eq "Price"){
         for my $i (@LIST){
            my $price = &get_price($DATABASE[$i][$uuid_i]);
            my $sort_name = sprintf("%8.2f:%i",$price,$i);
            push(@SORT,$sort_name);
         }
      } else {
         die();
      }
      @SORTED = sort { substr($a,0, 8) <=> substr($b,0, 8)  } @SORT;
      @MAP = ();
      $hlist->delete('all');
      for my $place (0..$#SORTED){
         my $this = $SORTED[$place];
         if($this =~ /(\d+.*)\:(\d+.*)/){
            my $sort_criteria = $1;
            my $index         = $2;
            if($sort_by eq "CMC"){$sort_criteria = "";}
            if($sort_criteria =~ /999999/){
               $sort_criteria = "NA";
            }
            my $display_string = &build_string_for($index,$sort_criteria);

            $MAP[$place] = $index;
            $hlist->add($place ,-text=>$display_string);
         }
      }
   }
}
###############################################################################
sub output_search_list{
   for my $each (@CURRENT_SEARCH){
      my $name = $DATABASE[$each][$name_i];
      my $uuid = $DATABASE[$each][$uuid_i];
      printf("%-30s %-s\n",$name,$uuid);
   }
}
###############################################################################
sub update_status{
   my ($to) = @_;
   $status=$to;
   $mw->update();
   
}

###############################################################################
sub pick_out_soup{

   ## start from starting;
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
   
   
}


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
         if($line =~ /^(.*)\:(.*\:.*)/){
            push(@WORKING,$1);
         } elsif($line =~ /^(.*)\:/){
            push(@WORKING,$1);
         }
      }   
      &redisplay_working();
   }
}

###############################################################################
sub add_to_working{
   my $uuid = $DATABASE[$starting][$uuid_i];

   push(@WORKING,$uuid);
   &redisplay_working();
}

###############################################################################
sub get_i_for_uuid{
   my ($uuid) = @_;
   
   for my $i (0..$#DATABASE){
      if($DATABASE[$i][$uuid_i] eq $uuid){
         return $i;
      }
   }
   print "UUID not found $uuid\n";
}

###############################################################################
sub redisplay_working{
   $hlist2->delete('all');
   
   open(WORKING,">working_set.txt");
   my $place = 0;
   for my $uuid (@WORKING){
      my $i = &get_i_for_uuid($uuid);
      print WORKING "$uuid:$DATABASE[$i][$name_i]\n";
   
      my $display_string = &build_string_for($i);
      $MAP2[$place] = $i;
      $hlist2->add($place ,-text=>$display_string);
      $place++;
   }
   
   close(WORKING);
}
###############################################################################
sub remove_from_working{

   my $what_uuid= $DATABASE[$starting][$uuid_i];

   my @TEMP = @WORKING;
   @WORKING = ();
   for my $i (@TEMP){
      if($i ne $what_uuid){
         push(@WORKING,$i);
      }   
   }

   &redisplay_working();

}

###############################################################################
sub download_art{

   &hlist_select_call($next_art);
   
   $next_art++;
}
###############################################################################
sub find_similair{

   my @LIST = &get_starting_list();
   
   $similair_uuid=$DATABASE[$starting][$uuid_i];

   @LIST = &filter_on_legal(@LIST);
   @LIST = &filter_on_must_color(@LIST);
   @LIST = &filter_on_not_allowed_color(@LIST);
   @LIST = &filter_on_allowed_color(@LIST);
   @LIST = &filter_on_types(@LIST);
   @LIST = &filter_not_types(@LIST);
   @LIST = &filter_on_subtype(@LIST);
   @LIST = &filter_on_supertype(@LIST);
   # @LIST = &clip_dups(@LIST);
   
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
   
   @CURRENT_SEARCH=@LIST;
   &hlist_select_call(0);
}
###############################################################################

sub build_string_for{
   my ($i,$extra) = @_;
   if(!defined($extra)){
      $extra = "";
   }
   
   my $cmc  = $DATABASE[$i][$manavalue_i];
   my $name = $DATABASE[$i][$name_i];
   my $colors = $DATABASE[$i][$color_i];
   
   $colors =~ s/\s//g;
   $colors =~ s/\,//g;
   
   return sprintf("%2i %-5s %-s %s",$cmc,$colors,$name,$extra);
   
}   

##################################################################################
sub splitter{   

}

##################################################################################

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
   
   &time_log("hlist_select_call","start");

   
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
 #  print "name = $ascii_name =>";
   $ascii_name = &clean_name_for_dos($ascii_name);
 #  print "name = $ascii_name\n";

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
   
   
   ## &show_prices($uuid);
   
   my $price = &get_price($uuid);
   
   open(CURIOUS,">last_card.txt");
   for my $z (0..$#{$DATABASE[0]}){
      print CURIOUS "$DATABASE[0][$z] -> $DATABASE[$i][$z]\n";
   }
   close(CURIOUS);
   
   my $rulings_text= &get_rulings($uuid);
   $rulings->delete('0.0','end');
   $rulings->insert('end',$rulings_text);

   
   $notes1 = "Cardkingdom price = ".$price;
   $notes2 = "Set:$actual";
   
   my $j = $LEGAL_HASH{$uuid};
   
   $notes3 = "Legal:";

   for my $i (0..$#{$LEGALS[$j]}){
      if($LEGALS[$j][$i] eq "Legal"){
         $notes3 .= "$LEGALS[0][$i]:";
      }
   }
   $notes3 .= " || found:$search_found";

   
   &time_log("hlist_select_call","stop");

   $mw->after(1,\&get_art_and_display);
    
}

##################################################################################
sub build_rulings_table{
   my $longest_rules = 0;
   my $long_uuid;
   for my $i (1..$#RULINGS){
      my $uuid = $RULINGS[$i][$ruling_uuid_i];
      my $this = "";
      if(defined($HRULES{$uuid})){
         $this = $HRULES{$uuid};
      }   
      if($this =~ /\w/){
         $this .= ":::";
      }
      $this .= $RULINGS[$i][$ruling_text_i];
      
      $HRULES{$uuid}=$this;
      my $length= length($this);
      if($length > $longest_rules){
         $longest_rules = $length;
         $long_uuid=$uuid;
      }
   } 
   print "Worst uuid = $long_uuid\n";
   my $i = &get_i_for_uuid($long_uuid);
   print "$DATABASE[$i][$name_i]\n";
}

##################################################################################
sub get_rulings{
   my ($uuid) = @_;
   
   &time_log("get_rulings","start");

   my $final="";
   my $blob=$HRULES{$uuid};
   if(defined($blob)){
      my @SEGMENTS = split(/\:\:\:/,$blob);
      my $text = "";
      my $n = 1;
      for my $seg (@SEGMENTS){
         my $num = sprintf("%02i",$n);
         $text .= "$num) $seg EENNDD ";
         $n++;
      }
      my @T = split(/\s+/,$text);
      my $subpiece = "";
      for my $t (@T){
         if($t eq "EENNDD"){
            $final .= $subpiece."\n";
            $subpiece = "";
         } else {
            my $try = $subpiece." $t ";

            if(length($try) > $note_width_in_chars){
               $final .= $subpiece."\n";
               $subpiece = "      $t ";
            } else {
               $subpiece=$try;
            }
         }   
      }
      if($subpiece ne ""){
         $final .= $subpiece."\n";
      }

      &time_log("get_rulings","stop");
   } else {
      $final = "no rulings";
   }
   
   
   return $final;


}

##################################################################################
sub get_price{
   my ($uuid) = @_;
   
   if(defined($PRICE_HASH{$uuid})){
      return $PRICE_HASH{$uuid};
   }
   
   return 999999;


}

##################################################################################
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
       if($ALLOWED_TYPES[$i] == 1){
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
      }
   }
   
   return @NEW_LIST;

}

##################################################################################
sub is_legal{
   my ($i) = @_;
   my $uuid = $DATABASE[$i][$uuid_i];
   
   if($legality_selected eq "dont_care"){
      return 1;
   }   
      
   if($legality_selected ne $last_legal_set){
      for my $col (0..$#{$LEGALS[0]}){
         if($LEGALS[0][$col] eq $legality_selected){
            $selected_legality_i = $col;
         }
      }   
      $last_legal_set = $legality_selected;
   }
         
   
   my $j = $LEGAL_HASH{$uuid};
   if($LEGALS[$j][$selected_legality_i] eq "Legal"){
      return 1;
   } else {
      return 0;
   }
   return 0;
   
}

##################################################################################
sub filter_on_legal{
   my (@LIST) = @_;
   my @NEW_LIST;
   
   for my $i (@LIST){
      if(&is_legal($i)){
         push(@NEW_LIST,$i);
      } else {
         my $name = $DATABASE[$i][$name_i];
         print DBG "$name is not legal $DATABASE[$i][$uuid_i]\n";
      }
   }     
   return @NEW_LIST;
   
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
    
   return @NEW_LIST;

}
##################################################################################
sub filter_on_name{
   my ($filt,@LIST) = @_;
   if(!defined($filt)){return @LIST;}
   
   $filt =~ s/\s+/\.\*/g;
   
   if($filt !~ /\w/){return @LIST;}
   my @NEW_LIST = ();
   for my $i (@LIST){
      print DBG "$DATABASE[$i][$name_i]";
      if($DATABASE[$i][$name_i] =~ /$filt/i){
          push(@NEW_LIST,$i);
          print DBG "In\n";
      } else {
         print DBG "out\n";
      }
   }
   return @NEW_LIST;
}

##################################################################################
sub init{

   &time_log("init","start");
   @THE_SETS=&read_csv("sets.csv");
   $setcode_i = &find_col("code",@{$THE_SETS[0]});
   $setname_i = &find_col("name",@{$THE_SETS[0]});

   @DATABASE = &read_csv("cards.csv");
   
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
   $language_i   = &find_col("language",@{$DATABASE[0]});
   
   @LEGALS = &read_csv("cardLegalities.csv");
   $uuid_leg_i    = &find_col  ("uuid",@{$LEGALS[0]});
   for my $j (1..$#LEGALS){
      $LEGAL_HASH{$LEGALS[$j][$uuid_leg_i]} = $j;
   }
   open(DBG_LEGALS,">legal_dbg.txt");
   for my $row (1..$#LEGALS){
      for my $col (0..$#{$LEGALS[0]}){
         my $which=$LEGALS[0][$col];
         print DBG_LEGALS "$which=>$LEGALS[$row][$col],";
      }
      print DBG_LEGALS "\n";
   }
   close(DBG_LEGALS);
   
   
   
   
   ## cardIdentifiers.csv
   @CARD_IDS = &read_csv("cardIdentifiers.csv");
    
   $card_id_uuid_i       = &find_col("uuid",@{$CARD_IDS[0]});
   $card_id_scryfallId_i = &find_col("scryfallId",@{$CARD_IDS[0]});
   
   
   
   
   @PRICES  =&read_csv("cardPrices.csv");
   $price_uuid_i         = &find_col("uuid",@{$PRICES[0]});
   $price_price_i        = &find_col("price",@{$PRICES[0]});
   $price_price_provider = &find_col("priceProvider",@{$PRICES[0]});
   $price_currency_i     = &find_col("currency",@{$PRICES[0]});
   $price_listing_i      = &find_col("providerListing",@{$PRICES[0]});
   for my $i (1..$#PRICES){
      if($PRICES[$i][$price_currency_i] eq "USD"){
         if(($PRICES[$i][$price_price_provider] eq "cardkingdom") && ($PRICES[$i][$price_listing_i] eq "retail")){
            my $uuid=$PRICES[$i][$price_uuid_i];
            if($PRICES[$i][$price_uuid_i] eq $uuid){
               my $price = $PRICES[$i][$price_price_i];
               if(!defined($PRICE_HASH{$uuid})){
                  $PRICE_HASH{$uuid} = $price; 
               
               } elsif($price < $PRICE_HASH{$uuid}){
                  $PRICE_HASH{$uuid} = $price; 
               }
            }   
         }   
      }
   }
   &update_status("building cheaplist");
   &build_cheapest_list();
   
   @RULINGS = &read_csv("cardRulings.csv");
   $ruling_uuid_i = &find_col("uuid",@{$RULINGS[0]});
   $ruling_text_i = &find_col("text",@{$RULINGS[0]});
   
   &update_status("building up rulings hash");
   &build_rulings_table();
   
   &update_status("building up keywords...");
    
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
   
   
   &update_status("building hash for downloads from uuids...");
   &build_hash_for_downloadname_from_uuid();
   
   &update_status("initialing working list");
   &init_working();

   $ready =1;
   &pick_a_random_card(0);
   
   &update_status("ready!");

   &time_log("init","stop");   
}

###############################################################################
sub build_hash_for_downloadname_from_uuid{
   for my $i (1..$#CARD_IDS){
      my $uuid = $CARD_IDS[$i][$card_id_uuid_i];
      $DOWNLOAD_H{$uuid}=$CARD_IDS[$i][$card_id_scryfallId_i];
   }   
}
###############################################################################
sub get_download_name_for_uuid{
   my ($uuid) = @_;
   
   return $DOWNLOAD_H{$uuid};
   
}

###############################################################################
sub read_csv{
   my ($file) = @_;
   &update_status("reading $file...");


   my @CSV;
   # Create a new CSV parser object with options
   my $csv = Text::CSV->new({
       binary    => 1,
       auto_diag => 1,
       sep_char  => ',',
   });

   # Open the CSV file with UTF-8 encoding
   open(my $data, '<:encoding(utf8)', $file) or die "Could not open '$file': $!\n";

   # Read and parse each line
   my $next = 0;
   my $col  = 0;
   while (my $row = $csv->getline($data)) {
       for my $each (@$row){
          $CSV[$next][$col]= $each;
          $col++;
       }
       $next++;
       $col=0;

   }

   # Check for end-of-file or errors
   if (not $csv->eof) {
       $csv->error_diag();
   }

   close $data;
   return @CSV;
}

##############################################################################
sub filter_out_nonenglish{
   my (@LIST) = @_;
   my @NEW_LIST;
   for my $i (@LIST){
      my $lang=$DATABASE[$i][$language_i];
      if($lang =~ /english/i){
         push(@NEW_LIST,$i);
      }
   }
   return @NEW_LIST;

}
##############################################################################
sub build_cheapest_list{
   my %PRICE_BY_CARD;
   my %MAP_TO_I;;
   print "Building cheap list!!!\n";
   open(DROPPED,">dropped.txt");
   
   for my $i (1..$#DATABASE){
      my $name = $DATABASE[$i][$name_i];
      my $fname = $DATABASE[$i][$fname_i];
      my $use = $name.":".$fname;
      my $uuid=$DATABASE[$i][$uuid_i];
      if(&is_legal($i)){
         my $price = &get_price($uuid);
         if(!defined($PRICE_BY_CARD{$use})){
            $PRICE_BY_CARD{$use}=$price;
            $MAP_TO_I{$use}=$i;
         } elsif($price < $PRICE_BY_CARD{$use}){
            my $was = $MAP_TO_I{$use};
            my $name = $DATABASE[$was][$name_i];
            my $new = $DATABASE[$i][$name_i];
            print DROPPED "$was $name; replaced with $new\n";
            $PRICE_BY_CARD{$use}=$price;
            $MAP_TO_I{$use}=$i;
         }
      }
   }
   print DROPPED "*****\n";
   for my $key (keys(%PRICE_BY_CARD)){
      my $i     = $MAP_TO_I{$key};
      push(@CHEAPEST_LIST,$i);
      print DROPPED "$DATABASE[$i][$name_i]\n";
   }
   close(DROPPED);
   
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

sub find_col{
   my ($what,@COLS) = @_;
   for my $col (0..$#COLS){
      my $against=lc($COLS[$col]);
    #  $against=~ s/^\s*(.*)\s*/$1/;
      if($against eq lc($what)){ 
          return $col;
      }
   }
   
   print "$what not found!\n";
   for my $col (0..$#COLS){
      print "|$col -> $COLS[$col]|\n";
   }   
   
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
sub display_null{
   &display_image("new-image.jpg");



}
##################################################################################
sub display_image{
   my ($image_file) = @_;
   
   &time_log("display_image","start");


   my $orig_image = $mw->Photo('-format' => 'jpeg', -file => "$image_file");
   
   my $max_y = $orig_image->height();
   my $max_x = $orig_image->width();
      
   my $mod = 2;
   
   if($turn_right){

      my @NEW;   
   
      for my $x (0..$max_x/$mod-1){
         for my $y (0..$max_y/$mod-1){
            my $target_x = $x*$mod;
            my $target_y = $y*$mod;

            my @P = $orig_image->get($target_x,$target_y+($mod/2));
            my $load_y=($max_y/$mod)-$y;
            $NEW[$x][$load_y-1]=sprintf("#%02x%02x%02x",@P);
         }
      } 

      my $image=$mw->Photo();

      $image->blank;
      $image->put(\@NEW,-to=>0,0);
      $image_lbl->configure(-image=>$image);
      $image_lbl->pack;      
      $mw->update();
   } else {
      my $image=$mw->Photo();
      $image->blank;
      $image->copy($orig_image,-subsample=>2,2);
      $image_lbl->configure(-image=>$image);
      $image_lbl->pack;
   }
   
   &time_log("display_image","stops");

}

##################################################################################
sub get_art_and_display{   
   
   &time_log("get_art_and_display","start");

   my $side;
   if($get_front){
      $side = "front";
   } else {
      $side = "back";
   }
   my $dir1 = substr($get_this_thing,0,1);
   my $dir2 = substr($get_this_thing,1,1);
   
   
   my $get = "https:\/\/cards.scryfall.io/large/$side/".$dir1."/".$dir2."/$get_this_thing\.jpg";
   
   my $response   = $ua->get($get,':content_file' => "ART2\\".$ascii_name.".jpg");
   if($response->is_success){
   } else {
      print "response is bad\n";
   }
   
   &time_log("get_art_and_display","stop");
   
   &display_image("ART2\\$ascii_name.jpg");
}

##################################################################################
sub pick_a_random_card2{
   my ($jank) = @_;
   my $not_done = 1;
   &update_status("picking random card!");

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
   
   &update_status("ready!");
}
##################################################################################
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
##################################################################################
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
##################################################################################
sub build_type_list{
   my %H;
   
   my $types_i = &find_col("types",@{$DATABASE[0]});
   for my $i (1..$#DATABASE){
      my $types = $DATABASE[$i][$types_i];
      my @T=split(/\s+/,$types);
      for my $t (@T){
         $H{$t}++;
      }
   }
   for my $key (keys(%H)){
      print "$key => $H{$key}\n";   
   }

}

##################################################################################
sub time_log{
   my ($ref,$which) = @_;
   
   my $t = time;
   
   if($which eq "start"){
      $TIME_REF{$ref}=$t;
   } else {
      my $dt = $t-$TIME_REF{$ref};
      $TIME_DATA_N{$ref}++;
      $TIME_DATA_DT{$ref} += $dt;
   }
}
##################################################################################
sub show_timing{

   for my $key (keys(%TIME_REF)){
      my $n = $TIME_DATA_N{$key};
      my $t = $TIME_DATA_DT{$key};
      my $avg = int(1000*$t/$n)/1000;
      printf("%-30s %f %i\n",$key,$avg,$n);
   
   
   }

}
 