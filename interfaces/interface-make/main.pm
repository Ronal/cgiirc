# NOTE -- This file is generated by running make-js-interfaces.pl
package **BROWSER;

use strict;
use vars qw/@ISA $standardheader/;
$standardheader = <<EOF;
<!-- This is part of CGI:IRC 0.5 (http://cgiirc.org)
  == Copyright (C) 2000-2008 David Leadbeater <http://dgl.cx>
  == Released under the GNU GPL
  -->
EOF

if(defined $::config->{javascript_domain}) {
  $standardheader .= "<script>
  document.domain = '$::config->{javascript_domain}';
  </script>\n";
}

use default;
@ISA = qw/default/;
my %colours = (
	  '00' => '#FFFFFF', '01' => '#000000', '02' => '#0000FF', 
	  '03' => '#008000', '04' => '#FF0000', '05' => '#800000', 
	  '06' => '#800080', '07' => '#FF6600', '08' => '#FFFF00', 
	  '09' => '#00FF00', '10' => '#008080', '11' => '#00FFFF', 
	  '12' => '#0000FF', '13' => '#FF00FF', '14' => '#808080', 
	  '15' => '#C0C0C0');

my %options = (
   timestamp => {
      type => 'toggle',
      info => 'Display a timestamp next to each message', 
      img => 'time.gif'
   },
   font => { 
      type => 'select',
      options => [qw/serif sans-serif fantasy cursive monospace/,
                 'Arial Black', 'Comic Sans MS', 'Fixedsys',
                 'Tahoma', 'Verdana'],
      info => 'The font that messages are displayed in',
      img => 'font.gif'
   },
   shownick => {
      type => 'toggle',
      info => 'Show your nickname next to the text entry box',
      img => 'entry.gif'
   },
   smilies => {
      type => 'toggle',
      info => 'Convert smilies into pictures',
      img => 'smile.gif'
   },
   scrollback => {
      type => 'toggle',
      info => 'Store all scrollback data (uses more memory)',
		img => 'scrollback.gif',
   },
   'actsound' => {
      type => "toggle",
      info => "Play a sound when activity directed at you occurs",
		img => 'actsound.gif',
   },
   'joinsound' => {
      type => "toggle",
      info => "Play a sound when some one joins a channel",
		img => 'joinsound.gif',
   },
);

my(%output_status, %output_none, %output_active);

sub new {
   my($class,$event, $timer, $config, $icookies) = @_;
   my $self = bless {}, $class;
   tie %$self, 'IRC::UniqueHash';
   if(defined $config->{javascript_domain}) {
     _out("document.domain = " . _escapejs($config->{javascript_domain}) . ";");
   }
   my $tmp='';
   for(keys %$icookies) {
      $tmp .= "$_: " . _escapejs($icookies->{$_}) . ', ';
   }
   $tmp =~ s/, $//;
   _out('parent.options = { ' . $tmp . '};');
   $event->add('user add', code => \&useradd);
   $event->add('user del', code => \&userdel);
   $event->add('user change nick', code => \&usernick);
   $event->add('user change', code => \&usermode);
   $event->add('user self', code => \&mynick);
   $event->add('user 005', code => sub { _func_out('prefix',$_[1])});
   $event->add('user connected', code => sub { _out('parent.connected = 1;')
   }); 
   $self->add('Status', 0);
   _func_out('witemnospeak', 'Status');
   _func_out('fontset', $icookies->{font}) if exists $icookies->{font};
   _func_out('enable_sounds') if ((exists $icookies->{actsound} || exists $icookies->{joinsound}) && ($icookies->{actsound} || $icookies->{joinsound}));

   if(exists $::config->{'output status'}) {
      @output_status{split /,\s*/, $::config->{'output status'}} = 1;
   }

   if(exists $::config->{'output none'}) {
      @output_none{split /,\s*/, $::config->{'output none'}} = 1;
   }
   
   if(exists $::config->{'output active'}) {
      @output_active{split /,\s*/, $::config->{'output active'}} = 1;
   }
   
   return $self;
}

sub end {
   _out('parent.connected = 0;');
}

sub _out {
   unless(print "<script>$_[0]</script>\r\n") {
      $::needtodie++;
   }
}

sub _func_out {
   my($func,@rest) = @_;
   @rest = map(ref $_ eq 'ARRAY' ? _outputarray($_) : _escapejs($_), @rest);
   if($func eq 'witemaddtext') {
      return 'parent.' . $func . '(' . _jsp(@rest) . ');';
   }
   _out('parent.' . $func . '(' . _jsp(@rest) . ');');
}

sub _escapejs {
   my $in = shift;
   return "''" unless defined $in;
   $in =~ s/\\/\\\\/g;
   $in =~ s/'/\\'/g;
   $in =~ s/<\/script/<\\\/\\script/g;
   if(defined $_[0]) {
      return "$_[0]$in$_[0]";
   }
   return '\'' . $in . '\'';
}

sub _escapehtml {
   my $in = shift;
   return "''" unless defined $in;
   $in =~ s/</&lt;/g;
   $in =~ s/>/&gt;/g;
   $in =~ s/"/&quot;/g;
   return $in;
}

# XXX: switch this to use a proper JSON library one day..

sub _jsp {
   return join(', ', @_);
}

sub _outputarray {
   my $array = shift;
   return '[' . _jsp(map(_escapejs($_), @$array)) . ']';
}

sub _outputhash {
   my $hash = shift;
   return '{' . _jsp(map(_escapejs($_) . ":" . _escapejs($hash->{$_}), keys %$hash)) . '}';
}

sub useradd {
   my($event, $nicks, $channel) = @_;
   _func_out('channeladdusers', $channel, $nicks);
}

sub userdel {
   my($event, $nick, $channels) = @_;
   _func_out('channelsdeluser', $channels, $nick);
}

sub usernick {
   my($event,$old,$new,$channels) = @_;
   _func_out('channelsusernick', $old, $new);
}

sub usermode {
   my($event,$nick, $channel, $action, $type) = @_;
   _func_out('channelusermode', $channel, $nick, $action, $type);
}

sub mynick {
   my($event, $nick) = @_;
   _func_out('mynick', $nick);
}

sub exists {
   return 1 if defined &{__PACKAGE__ . '::' . $_[1]};
}

sub query {
   return 1;
}

sub style {
   my($self, $cgi, $config) = @_;
   my $style = $cgi->{style} || 'default';
   $cgi->{style} =~ s/[^a-z]//gi;
   open(STYLE, "<interfaces/style-$style.css") or die("Error opening stylesheet $style: $!");
   print <STYLE>;
   close(STYLE);
}

sub makeline {
   my($self, $info, $html) = @_;
   my $target = defined $info->{target} ? $info->{target} : 'Status';

   if(ref $target eq 'ARRAY') {
     my %tmp = %$info;
     my $text = '';
	  for(@$target) {
	     $tmp{target} = $_;
        $text .= $self->makeline(\%tmp, $html) . "\r\n";
	  }
	  return $text;
   }

   my $out = "";
   if(not exists $self->{$target}) {
      if(defined $info && ref $info && exists $info->{create} && $info->{create}) {
	     $self->add($target, $info->{type} eq 'join' ? 1 : 0);
	  }elsif($target ne '-all') {
         $target = 'Status';
	  }
   }elsif($info->{type} eq 'join') {
      $out = "parent.joinsound();";
   }

   $info->{type} =~ s/^(\w+ \w+) .*/$1/;
   return if exists $output_none{$info->{type}};
   $target = "Status" if exists $output_status{$info->{type}};
   $target = "-active" if exists $output_active{$info->{type}};
   
   if($info->{style}) {
      $html = "<span class=\"main-$info->{style}\">$html</span>";
   }
   return $out . _func_out('witemaddtext', $target, $html . '<br>', $info->{activity} || 0, 0);
}

sub lines {
   my($self, @lines) = @_;
   _out(join("\r\n", @lines)."\r\nparent.witemredraw();");
.$not ie
   print "<!-- mozilla padding -->\r\n";
.$end
}

sub header {
   my($self, $cgi, $config, $fg, $bg) = @_;
   _func_out('maincolor', $fg, $bg);
}

sub error {
   my($self,$message) = @_;
   $self->lines($self->makeline({ target => 'Status'}, $message));
   _func_out('disconnected');
}

sub add {
   my($self,$add,$channel) = @_;
   return if not defined $add;
   $self->{$add}++;
   _func_out('witemadd', $add, $channel);
   _func_out('witemchg', $add) if $channel;
}

sub del {
   my($self, $del) = @_;
   return if not defined $del;
   _func_out('witemdel', $del);
   return if not exists $self->{$del};
   delete($self->{$del});
}

sub clear {
   my($self, $window) = @_;
   _func_out('witemclear', $window);
}

sub active {
   my($self, $window) = @_;
   _func_out('witemchg', $window);
}

sub smilie { # js runs in fmain. (XXX: doesn't actually work?)
   return '<img src="'.$_[1].'" alt="' . $_[2] . '">';
}

sub link {
   shift; # object
   return "<a href=\"$_[0]\" target=\"cgiirc@{[int(rand(200000))]}\" class=\"main-link\">$_[1]</a>";
}

sub frameset {
   my($self, $scriptname, $config, $random, $out, $interface, $style) = @_;
   if($config->{balance_servers}) {
      my @balance_servers = split /,\s*/, $config->{balance_servers};
      $scriptname = $balance_servers[rand @balance_servers] . "/$scriptname";
   }
print <<EOF;
$standardheader
<html>
<head>
<title>CGI:IRC - Loading</title>
<link rel="stylesheet" href="$config->{script_login}?interface=**BROWSER&item=style&style=$style" />
<link rel="SHORTCUT ICON" href="$config->{image_path}/favicon.ico">
<script language="JavaScript"><!--
function form_focus() {
   if(document.frames && document.frames.fform)
	  document.frames.fform.fns();
}
//-->
</script>
</head>
<frameset
.$just konqueror opera7
rows="40,*,60,0"
.$else
rows="40,*,25,0"
.$end
framespacing="0" border="0" frameborder="0" onfocus="form_focus()" onload="form_focus()"> 
<frame name="fwindowlist" src="$scriptname?$out&item=fwindowlist&style=$style"
scrolling="no">
<frameset cols="*,120" framespacing="0" border="0" frameborder="0">
<frame name="fmain"
src="$scriptname?item=fmain&interface=$interface&style=$style">
<frame name="fuserlist"
src="$scriptname?item=fuserlist&interface=$interface&style=$style"
scrolling="auto">
</frameset>
<frame name="fform"
src="$scriptname?item=fform&interface=$interface&style=$style" scrolling="no"
framespacing="0" border="0" frameborder="0" resize="no">
<frame name="hiddenframe" src="$scriptname?item=blank&style=$style"
scrolling="no" framespacing="0" border="0" frameborder="0" resize="no">
<noframes>
This interface requires a browser that supports frames and javascript.
</noframes>
</frameset>
</html>
EOF
}

sub blank {
   return '';
}

sub ctcpping {
   my($self, $nick, $params) = @_;
   _func_out('sendcmd',"/ctcpreply $nick PING $params");
   1;
}

sub ping {
   1;
}

sub sendping {
   _func_out('sendcmd',"/noop");
}

sub help {
   my($self,$config) = @_;
   my %helpmap = ( "russian" => ".ru" );
   my $extra = $helpmap{$::formatname} || "";

   open(HELP, "<" . $::help_path . "help$extra.html") or do {
     _func_out('doinfowin', '-Help', "Help file not found!");
     return;
   };
   eval { local $SIG{__DIE__}; binmode HELP, ':utf8'; };
   local $/;
   my $help = <HELP>;
   close HELP;
   $help =~ s/[\n\r]/ /g;
   _func_out('doinfowin', '-Help', $help);
}

sub setoption {
   my($self, $name, $value) = @_;
   _func_out('setoption', $name, $value);
   $self->options({}, {}, $main::config)
}

sub options {
   my($self, $cgi, $irc, $config) = @_;
   $config = $irc unless ref $config;
   my $ioptions = $main::ioptions;

   my $out = "<html><head><title>CGI:IRC Options</title></head><body class=\"options-body\"><h1 class=\"options-title\">Options</h1>These options affect the appearence of CGI:IRC, they will stay between sessions provided cookies are turned on.<form><table border=0 class=\"options-table\"> ";

   for my $option(sort keys %options) {
      my $o = $options{$option};
      my $value = defined $ioptions->{$option} ? $ioptions->{$option} : '';
      
      $out .= "<tr><td>" . (exists $o->{img} ? "<label for=\"$option\"><img src=\"$config->{image_path}/$o->{img}\"> " : '') . "<b>$option</b>" . (exists $o->{info} ? " ($o->{info})" : '') . "</td><td>";
      if($o->{type} eq 'toggle') {
         $out .= "<input class=\"options-checkbox\" type=\"checkbox\" name=\"$option\" value=\"1\"" . 
            ($value? ' checked=1' : '')."\" onclick=\"parent.fwindowlist.send_option(this.name, this.checked == true ? this.value : 0);return true;\">";
      }elsif($o->{type} eq 'select') {
         $out .= "<select name=\"$option\" onchange=\"parent.fwindowlist.send_option('$option', this.options[this.selectedIndex].value);return true\" class=\"options-select\">";
         for(@{$o->{options}}) {
            $out .= "<option class=\"options-option\" name=\"$option\" value=\"$_\"".($_ eq $value ? ' selected=1' : '') . ">$_</option>";
         }
         $out .= "</select>";
      }else{
         $out .= "<input class=\"options-input\" type=\"text\" name=\"$option\" value=\""._escapehtml($value)."\" onChange=\"parent.fwindowlist.send_option(this.name, this.value);return true;\">";
      }
      $out .= "</label></td></tr>";
   }
   
$out .= "
</table></form><span onclick=\"parent.fwindowlist.witemdel('-Options')\" class=\"options-close\">close</span></body></html>
";
   $out =~ s/\n//g;
   _func_out('doinfowin', '-Options', $out);
}

sub say {
   my($self) = @_;
   return 'ok';
}

sub reconnect {
  my($self, $url, $text) = @_;
  return "<a href=\"$url\" target=\"_top\" onclick='if(parent.fwindowlist.reconnect){parent.fwindowlist.reconnect();return false;}'>$text</a>";
}

.$sub fwindowlist
.$sub fmain
.$sub fuserlist
.$sub fform

1;
