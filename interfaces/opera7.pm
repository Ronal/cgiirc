# NOTE -- This file is generated by running make-js-interfaces.pl
package opera7;

use strict;
use vars qw/@ISA $standardheader/;
$standardheader = <<EOF;
<!-- This is part of CGI:IRC 0.5
  == http://cgiirc.sourceforge.net/
  == Copyright (C) 2000-2003 David Leadbeater <cgiirc\@dgl.cx>
  == Released under the GNU GPL
  -->
EOF

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

sub _jsp {
   return join(', ', @_);
}

sub _outputarray {
   my $array = shift;
   return '[' . _jsp(map(_escapejs($_), @$array)) . ']';
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
   print "<!-- mozilla padding -->\r\n";
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
print <<EOF;
$standardheader
<html>
<head>
<title>CGI:IRC - Loading</title>
<link rel="stylesheet" href="$config->{script_login}?interface=opera7&item=style&style=$style" />
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
rows="40,*,60,0"
framespacing="0" border="0" frameborder="0" onfocus="form_focus()" onload="form_focus()"> 
<frame name="fwindowlist" src="$scriptname?$out&item=fwindowlist&style=$style"
scrolling="no">
<frameset cols="*,120" framespacing="0" border="0" frameborder="0">
<frame name="fmain"
src="$scriptname?item=fmain&interface=$interface&style=$style" scrolling="yes">
<frame name="fuserlist"
src="$scriptname?item=fuserlist&interface=$interface&style=$style"
scrolling="yes">
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

   open(HELP, "<$::help_path\help${extra}.html") or do {
     _func_out('doinfowin', '-Help', "Help file not found!");
     return;
   };
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

sub fwindowlist {
   my($self, $cgi, $config) = @_;
   my $string;
   for(keys %$cgi) {
      next if $_ eq 'item';
	  $string .= main::cgi_encode($_) . '=' . main::cgi_encode($cgi->{$_}).'&';
   }
   $string =~ s/\&$//;
print $standardheader;
print q~
<html>
<head>
<script language="JavaScript">
<!--
// This javascript code is released under the same terms as CGI:IRC itself
// http://cgiirc.sourceforge.net/
// Copyright (C) 2000-2003 David Leadbeater <cgiirc\@dgl.cx>

//               none      joins    talk       directed talk
var activity = ['#000000','#000099','#990000', '#009999'];

var Witems = {};
var options = {};
var currentwindow = '';
var lastwindow = '';
var connected = 0;
var mynickname = '';
var prefixchars = '@%+ ';


function witemadd(name, channel) {
   if(Witems[name] || findwin(name)) return;
   name = name.replace(/\"/g, '&quot;');
   Witems[ name ] = { activity: 0, text: new Array, channel: channel, speak: 1,  info: 0 };
   if(channel) {
      Witems[name].users = {};
	  Witems[name].topic = '';
   }
   if(!currentwindow) currentwindow = name;
   wlistredraw();
}

function witemnospeak(name) {
   if(!Witems[name] && !(name = findwin(name))) return;
   Witems[name].speak = 0;
}

function witeminfo(name) {
   if(!Witems[name] && !(name = findwin(name))) return;
   Witems[name].info = 1;
}

function witemdel(name) {
   if(!Witems[name] && !(name = findwin(name))) return;
   if(name == 'Status') return;
   delete Witems[name];
   if(currentwindow == name) witemchg(lastwindow ? lastwindow : 'Status');
}

function witemclear(name) {
   if(!Witems[name] && !(name = findwin(name))) return;
   Witems[name].text.length = 0;
   witemredraw();
}


function channeladdusers(channel, users) {
   for(var i = 0;i < users.length;i++) {
      channeladduser(channel, users[i]);
   }
   userlist();
}

function channeladduser(channel, user) {
   var o = user.substr(0,1)
   if(prefixchars.lastIndexOf(o) != -1) {
      user = user.substr(1)
      while(prefixchars.lastIndexOf(user.substr(0,1)) != -1)
         user = user.substr(1)
   }

   if(!Witems[channel] && !(channel = findwin(channel))) return;

   Witems[channel].users[user] = { };

   if(o == '@') Witems[channel].users[user].op = 1;
   else if(o == '%') Witems[channel].users[user].halfop = 1;
   else if(o == '+') Witems[channel].users[user].voice = 1;
   else if(prefixchars.lastIndexOf(o) != -1)
      Witems[channel].users[user].other = o;
}

function channelsdeluser(channels, user) {
   if(channels == '-all-') {
      for(var i in Witems) {
         if(!Witems[i].channel) continue;
         if(!Witems[i].users[user]) continue;
         channeldeluser(i, user);
      }
      return;
   }
   for(var i = 0;i < channels.length; i++) {
      channeldeluser(channels[i], user);
   }
   userlist();
}

function channeldeluser(channel, user) {
   if(!Witems[channel] && !(channel = findwin(channel))) return;
   delete Witems[channel].users[user];
   userlist();
}

function channelsusernick(olduser, newuser) {
   for(var channel in Witems) {
      if(!Witems[channel].channel) continue;
      for(var nick in Witems[channel].users) {
	      if(nick == olduser) {
            Witems[channel].users[newuser] = Witems[channel].users[olduser];
            delete Witems[channel].users[olduser];
		   }
	   }
   }
   userlist();
}

function channelusermode(channel, user, action, type) {
   if(!Witems[channel] && !(channel = findwin(channel))) return;
   if(!Witems[channel].users[user]) return;

   if(action == '+') {
      Witems[channel].users[user][type] = 1;
   }else{
      delete(Witems[channel].users[user][type]);
   }
   userlist();
}

function channellist(channel) {
   if(!Witems[channel] && !(channel = findwin(channel))) return;
   var users = new Array();

   for (var i in Witems[channel].users) {
      var user = Witems[channel].users[i];
      if(user.other) i = user.other + i;
     else if(user.op == 1) i = '@' + i
	  else if(user.halfop == 1) i = '%' + i;
	  else if(user.voice == 1) i = '+' + i;
     else   i = ' ' + i;

      users[users.length] = i;
   }

   users = users.sort(usersort);
   return users;
}

function usersort(user1,user2) {
   var m1 = user1.substr(0,1);
   var m2 = user2.substr(0,1);

   if(m1 == m2) {
      if(user1.toUpperCase() < user2.toUpperCase()) return -1
	   return 1
   }

   if(prefixchars.lastIndexOf(m1) < prefixchars.lastIndexOf(m2)) return -1
   return 1
}

function witemchg(name) {
   if(!Witems[name] && !(name = findwin(name))) name = 'Status';
   if(Witems[name].activity > 0) Witems[name].activity = 0;
   lastwindow = (Witems[currentwindow] ? currentwindow : 'Status');
   currentwindow = name;
   wlistredraw();
   witemredraw();
   formfocus();
   userlist();
   retitle();
}

function retitle() {
   parent.document.title = 'CGI:IRC - ' + (Witems[currentwindow].info ? currentwindow.substr(1) : currentwindow) + (Witems[currentwindow].channel == 1 ? ' [' + countit(Witems[currentwindow].users) + '] ' : '');
}

function setoption(option, value) {
   options[option] = value;
   if(option == 'shownick' && value == 1)
      mynick(mynickname)
   else if(option == 'shownick') {
      if(parent.fform && parent.fform.nickchange) parent.fform.nickchange('');
   }else if(option == 'font')
      fontset(value)
}

function mynick(mynick) {
   mynickname = mynick;
   if(options.shownick != 1) return;
   if(parent.fform && parent.fform.nickchange) parent.fform.nickchange(mynick);
}

function maincolor(bg, fg) {
   var maindoc = parent.fmain.document;
   if(!maindoc) return;
   maindoc.bgColor = bg;
   maindoc.fgColor = fg;
}

function prefix(chars) {
   if(!/ /.test(chars))
      chars += ' '
   prefixchars = chars;
}

function witemchgnum(num) {
   var count = 1;
   for(var name in Witems) {
      if(count++ == num) return name;
   }
   return false;
}

function countit(obj) {
   var i = 0;
   for(var foo in obj) i++;
   return i;
}

function witemaddtext(name, text, activity, redraw) {
   if(name == '-all') {
      for(var window in Witems) {
        if(window == '-all') return
        if(Witems[window].info) continue;
	     witemaddtext(window, text, activity, redraw);
	  }
      return;
   }
   if(name == '-active') name = currentwindow

   if(!Witems[name] && !(name = findwin(name))) {
      if(!Witems["Status"]) return;
	  name = "Status";
   }
   
   if(options["timestamp"] == 1 && !Witems[name].info) {
      var D = new Date();
      text = '[' + (D.getHours() < 10 ? '0' + D.getHours() : D.getHours()) + ':' + (D.getMinutes() < 10 ? '0' + D.getMinutes() : D.getMinutes()) + '] ' + text;
   }
  
   if(options["scrollback"] == 0)
      Witems[name].text = Witems[name].text.slice(Witems[name].text.length - 200);
   if(!Witems[name].info)
      text = "<div class='main-item'>" + text + "</div>";
   Witems[name].text[Witems[name].text.length] = text;

   if(options["actsound"] == 1 && activity >= 3)
      playsound("actmsg");

   if(currentwindow != name && activity > Witems[name].activity)
       witemact(name, activity);
   if(redraw != 0 && currentwindow == name) witemredraw();
}

function witemact(name, activity) {
   if(!Witems[name] && !(name = findwin(name))) return;
   Witems[name].activity = activity;
   wlistredraw();
}

function witemredraw() {
   if(!parent.fmain.document) {
      setTimeout("witemredraw()", 1000);
	  return;
   }
   var doc = parent.fmain.document.body;
   var scrollok = 1;
   if(!currentwindow) currentwindow = 'Status';
   parent.fmain.document.getElementById('text').innerHTML = Witems[currentwindow].text.join('');
   if(Witems[currentwindow].info == 1) return;
   var doc = parent.fmain.window;
   var scroll = -1;
   while(doc.scrollY > scroll) {
	  scroll = doc.scrollY;
	  doc.scrollBy(0, 500);
   }
}

function wlistredraw() {
   var output='';
   for (var i in Witems) {
      output += '<span class="' + (i == currentwindow ? 'wlist-active' : 'wlist-chooser') + '" style="color: ' + activity[Witems[i].activity] + ';" onclick="witemchg(\'' + (i == currentwindow ? escapejs(lastwindow) : escapejs(i)) + '\')" onmouseover="this.className = \'wlist-mouseover\'" onmouseout="this.className = \'' + (i == currentwindow ? 'wlist-active' : 'wlist-chooser') + '\'">' + escapehtml(Witems[i].info ? i.substr(1) : i) + '</span>\r\n';
   }
   document.getElementById('windowlist').innerHTML = output;
}

function findwin(name) {
   var wname = new String(name);
   wname = wname.replace(/\"/g, '&quot;');
   for (var i in Witems) {
      if (i.toUpperCase() == wname.toUpperCase())
	     return i;
   }
   return false;
}

function escapejs(string) {
   out = string.replace(/\\\\/g,'\\\\\\\\').replace(/\\'/g, '\\\\\\'').replace(/\"/g, '&quot;');
   return out;
}

function escapehtml(string) {
   var out = string;
   out = out.replace(/</g, '&lt;');
   out = out.replace(/>/g, '&gt;');
   out = out.replace(/\"/g, '&quot;');
   return out;
}

function reconnect() {
	  do_quit();
     Witems = { };
     document.getElementById('iframe').src = document.getElementById('iframe').src + '&xx=yy';
}

function sendcmd(cmd) {
   if(cmd.substr(0, 10) == '/reconnect') {
      reconnect();
      return;
   }

   if(!connected && cmd.substr(0,5) != '/quit') {
	  alert('Not connected to IRC!');
	  return;
   }
   if(Witems[currentwindow] && !Witems[currentwindow].speak && cmd.substr(0,1) != '/') return;
   sendcmd_real('say', cmd, currentwindow);
}

function sendcmd_userlist(action, user) {
   if(!Witems[currentwindow].channel) return;
   if(!connected) {
      alert('Not connected to IRC!');
      return;
   }
   sendcmd_real('say', '/' + action + ' ' + user, currentwindow);
}

function sendcmd_real(type, say, target) {
   send_make({ item: 'say', cmd: type, say: say, target: target })
}

function senditem(item) {
   send_make({ item: item })
}

function send_option(name, value) {
   send_make({ cmd: 'options', name: name, value: value })
}

function send_make(data) {
   var xmlhttp = 0
   if(!xmlhttp) {
      for(var i in data) {
         document.hsubmit[i].value = data[i]
      }
      document.hsubmit.submit();
      for(var i in data) {
         document.hsubmit[i].value = ""
      }
   }else{
      xmlhttp_send(xmlhttp, data)
   }
}

function userlist() {
   if(!parent.fuserlist.userlist) {
      setTimeout(1000, "userlist()");
      return;
   }
   if(Witems[currentwindow] && Witems[currentwindow].channel == 1) {
      userlistupdate(channellist(currentwindow));
   }else{
      userlistupdate([' No channel']);
   }
   retitle();
}

function userlistupdate(list) {
   if(!parent.fuserlist.userlist) return;
   parent.fuserlist.userlist(list);
}

function formfocus() {
   if(parent.fform.location) parent.fform.fns();
}

function disconnected() {
   if(connected == 1) {
	  connected = 0;
	  do_quit();
	  witemaddtext('-all', '<b>Disconnected</b>', 1, 1);
   }
}

function doinfowin(name, text) {
   witemadd(name, 0);
   witemnospeak(name);
   witeminfo(name);
   witemclear(name);
   witemaddtext(name, text, 0, 1);
   witemchg(name);
}

function fontset(font) {
   if(parent.frames.fmain.document.getElementById('text')) {
      parent.frames.fmain.document.getElementById('text').style.fontFamily = font;
   }
}

function playsound(soundname) {
      top.window.focus();
}

function joinsound() {
   if(options["joinsound"] == 1)
      playsound("join");
}

~;
# ' (fix syntax hilight)
print <<EOF;
imghelpdn = new Image();
imghelpdn.src = "$config->{image_path}/helpdn.gif";
imghelpup = new Image();
imghelpup.src = "$config->{image_path}/helpup.gif";

imgoptionsdn = new Image();
imgoptionsdn.src = "$config->{image_path}/optionsdn.gif";
imgoptionsup = new Image();
imgoptionsup.src = "$config->{image_path}/optionsup.gif";

imgclosedn = new Image();
imgclosedn.src = "$config->{image_path}/closedn.gif";
imgcloseup = new Image();
imgcloseup.src = "$config->{image_path}/closeup.gif";

function do_quit() {
   var i = new Image();
   i.src = "$config->{script_form}?R=$cgi->{R}&cmd=quit";
}
// -->
</script>
<link rel="stylesheet" href="$config->{script_login}?interface=opera7&item=style&style=$cgi->{style}" />
</head>
<body onload="wlistredraw()" onkeydown="formfocus()" onbeforeunload="do_quit()" onunload="do_quit()" class="wlist-body">
<noscript>Scripting is required for this interface</noscript>
<table class="wlist-table">
<tr><td width="1">
<iframe src="$config->{script_nph}?$string" id="iframe" width="1" height="1" style="border:0"></iframe>

<iframe src="$config->{script_login}?interface=opera7&item=blank" id="iframe" width="1" height="1" style="border:0" name="hiddenframe"></iframe>
</td>
<td id="windowlist" class="wlist-container">
</td><td class="wlist-buttons">
<img src="$config->{image_path}/helpup.gif" onclick="if(connected == 0)return;sendcmd('/help');" class="wlist-button" onmousedown="this.src=imghelpdn.src" onmouseup="this.src=imghelpup.src;" onmouseout="this.src=imghelpup.src;" title="Help">
</td><td class="wlist-buttons">
<img src="$config->{image_path}/optionsup.gif" onclick="senditem('options');" class="wlist-button" onmousedown="if(connected == 0)return;this.src=imgoptionsdn.src" onmouseup="this.src=imgoptionsup.src;" onmouseout="this.src=imgoptionsup.src;" title="Options">
</td><td class="wlist-buttons">
<img src="$config->{image_path}/closeup.gif" onclick="if(connected == 0)return;if(currentwindow != 'Status'){sendcmd('/winclose')}else if(confirm('Are you sure you want to quit?')){do_quit();parent.location='$config->{script_login}'}" class="wlist-button" onmousedown="this.src=imgclosedn.src" onmouseup="this.src=imgcloseup.src;" onmouseout="this.src=imgcloseup.src;" title="Close">
</td></tr></table>

<form name="hsubmit" method="post" action="$config->{script_form}" target="hiddenframe">
<input type="hidden" name="R" value="$cgi->{R}">
<input type="hidden" name="cmd" value="say">
<input type="hidden" name="item" value="say">
<input type="hidden" name="say" value="">
<input type="hidden" name="target" value="">
<input type="hidden" name="name" value="">
<input type="hidden" name="value" value="">
</form>
</body></html>
EOF

}
sub fmain {
   my($self, $cgi, $config) = @_;
print <<EOF;
$standardheader
<html><head>
<link rel="stylesheet" href="$config->{script_login}?interface=opera7&item=style&style=$cgi->{style}" />
</head>
<body class="main-body"
onkeydown="if((event && ((event.keyCode < 30 || event.keyCode > 40) && (event.keyCode < 112 || event.keyCode > 123) && !event.ctrlKey)) && parent.fform.location) { parent.fform.fns(); return false; }"
>

<span class="main-span" id="text"></span>
</body></html>
EOF
}
sub fuserlist {
   my($self, $cgi, $config) = @_;
print <<EOF;
$standardheader
<html>
<head>
<script language="JavaScript">
<!--
var selected;

function fsubmit(form) {
   var action = form.action.options[form.action.selectedIndex].value;
   var user = form.user.value;

   if(!user || !action) {
      alert("No user or action selected");
      return false;
   }
   user = user.replace(/^[@%+ ]/, '');
   parent.fwindowlist.sendcmd_userlist(action, user);
   return false;
}

function deselect() {
   if(!selected) return;
   selected.className = 'userlist-item';
}

function userlist(users) {
   var tmp = '<table class="userlist-table">';
   for(var i = 0;i < users.length; i++) {
      var status = users[i].substr(0, 1);
      var user = users[i].substr(1);

      tmp += '<tr><td class="userlist-status"> ' + statushtml(status) + ' </td>'
          + '<td class="userlist-item" ' + 
        (user != 'No channel' ? 
          ' onmouseout="this.className=(this == selected ?'
          + '\\'userlist-selected\\':\\'userlist-item\\')"'
          + ' onmouseover="this.className=\\'userlist-hover\\'"'
          + ' onclick="' + 'this.className=\\'userlist-selected\\';'
          + 'deselect();selected = this;document.mform.user.value = \\''
          + parent.fwindowlist.escapejs(user) + '\\';return false;" ondblclick="fsubmit(document.mform);"'
          : '') + '>' + user + '</td></tr>';
   }
   tmp += '</table>';
   document.getElementById('usertable').innerHTML = tmp;
   document.mform.user.value = '';
}

function statushtml(status) {
   if(status == "@") {
      return '<div class="userlist-op">@</div>';
   }else if(status == "+") {
      return '<div class="userlist-voice">+</div>';
   }else if(status == "%") {
      return '<div class="userlist-halfop">%</div>';
   }else if(status == ' ') {
      return '';
   }else{
      return '<div class="userlist-other">' + status + '</div>';
   }
}

// -->
</script>
<link rel="stylesheet" href="$config->{script_login}?interface=opera7&item=style&style=$cgi->{style}" />
</head>

<body class="userlist-body" onkeydown="if((event && event.keyCode && ((event.keyCode < 30 || event.keyCode > 40) && (event.keyCode < 112 || event.keyCode > 123) && !event.ctrlKey)) && parent.fform.location) { parent.fform.fns(); return false; }">

<div class="userlist-div" id="usertable">

<table class="userlist-table">
<tr><td class="userlist-status"></td>
<td class="userlist-item">No channel</td></tr>
</table>

</div>

<form name="mform" onsubmit="return fsubmit(this)" class="userlist-form">
<input type="hidden" name="user">
<select name="action" class="userlist-select">
<option value="query">Query</option>
<option value="whois">Whois</option>
<option value="kick">Kick</option>
</select>
<input type="submit" class="userlist-btn" value="&gt;&gt;">
</form>

</body>
</html>
EOF
}
sub fform {
   my($self, $cgi, $config) = @_;
print <<EOF;
$standardheader
<html>
<head>
<html><head>
<script language="JavaScript"><!--
var shistory = [ ];
var hispos;
var tabtmp = [ ];
var tabpos;
var tablen;
var tabinc;

function fns(){
   if(!document.myform.say) return;
   document.myform.say.focus();
}

function t(item,text) {
   if(item.style.display == 'none') {
      item.style.display = 'inline';
	  text.value = '>>';
	  document.myform.say.style.width='10%' // For IE
     document.myform.say.style.width = document.body.offsetWidth - document.getElementById('excont').offsetWidth - 20
   }else{
      item.style.display = 'none';
	  text.value = '<<';
	  document.myform.say.style.width='90%'
   }
   fns();
}

function load() {
   fns();
EOF
if($ENV{HTTP_USER_AGENT} !~ /Mac_PowerPC/ && (!exists $config->{disable_format_input} || !$config->{disable_format_input})) {
print "document.getElementById('extra').style.display = 'none';"
}
print <<EOF;
   document.onkeypress = enter_key_trap;
}

function append(a) {
   document.myform["say"].value += a;
   fns();
}

function cmd() {
   if(document.myform["say"].value.length < 1) return false;
   hisadd();
   tabpos = 0;
   tabtmp = [];
   parent.fwindowlist.sendcmd(document.myform["say"].value);
   document.myform["say"].value = ''
   return false;
}

function nickchange(nick) {
   if(document.getElementById('nickname'))
      document.getElementById('nickname').innerHTML = nick;
}

function hisadd() {
   shistory[shistory.length] = document.myform["say"].value;
   hispos = shistory.length;
}

function hisdo() {
   if(shistory[hispos]) {
      document.myform["say"].value = shistory[hispos];
   }else{
      document.myform["say"].value = '';
   }
}

function enter_key_trap(e) {
   if(e == null) { // MSIE
      return keypress(event.srcElement, event);
   }else{ // Mozilla, Netscape, W3C
      return keypress(e.target, e);
   }
}

function keypress(srcEl, event) {
   if (srcEl.tagName != 'INPUT' || srcEl.name.toLowerCase() != 'say')
       return true;
   var charCode = event.charCode; // MSIE: undef, Mozilla: different when shifted
   var keyCode = event.keyCode; // the only one in MSIE, Mozilla: only special keys (up, down, etc)
   var which = event.which; // the only one in NN

   if(keyCode == null) { // NN
      charCode = which;
      if(which < 32) keyCode = which;
      // NN only has charcodes (and some special keys below 32, i.e. Esc)
   }
   if(charCode == null) charCode = keyCode; // MSIE

EOF
if(!exists $config->{disable_format_input} || !$config->{disable_format_input}) {
print <<EOF;
   if((charCode == 66 || charCode == 98) && event.ctrlKey) {
       // in NN/Mozilla charcodes are case sensitive
       append('\%B');
   }else if((charCode == 67 || charCode == 99) && event.ctrlKey) {
       append('\%C');
   }
EOF
}
print <<EOF;
   
   if(keyCode == 9) { // TAB
       var tabIndex = srcEl.value.lastIndexOf(' ');
	   var tabStr = srcEl.value.substr(tabIndex+1 || tabIndex).toLowerCase();

       if(tabpos == tabIndex && !tabStr && tabtmp.length) {
	      if(tabinc >= tabtmp.length) tabinc = 0;
	      for(var i = (tabinc > 0 ? tabinc : 0); i < tabtmp.length;i++) {
			 srcEl.value = srcEl.value.substr(0, tabIndex - tablen) + 
			       tabtmp[i] + (tabIndex == tablen ? ': ' : ' ');
			 tabpos = (tabIndex == -1 ? 0 : tabIndex) + tabtmp[i].length - tablen + (tabIndex == tablen ? 1 : 0);
			 tablen = tabtmp[i].length + (tabIndex == tablen ? 1 : 0);
			 tabinc++;
			 break;
		  }
	   }else{
	      tabtmp = [];
	      var list = parent.fwindowlist.channellist(parent.fwindowlist.currentwindow);
		  for(var i = 0;i < list.length; i++) {
		     var item = list[i].replace(/^[+%@ ]/,'');
		     if(item.substr(0, tabStr.length).toLowerCase() == tabStr) {
			    tabtmp[tabtmp.length] = item;
			 }
		  }
		  if(!tabtmp[0]) {
		     for(var i in parent.fwindowlist.Witems) {
			    if(i.substr(0, tabStr.length).toLowerCase() == tabStr) {
               if(parent.fwindowlist.Witems[i].speak)
				      tabtmp[tabtmp.length] = i;
				}   
			 }
		  }
		  if(!tabtmp[0]) return false;
		  srcEl.value = srcEl.value.substr(0, tabIndex) + 
		        (tabIndex > 0 ? ' ' : '') + tabtmp[0] + (tabIndex == -1 ? ': ' : ' ');
		  tablen = tabtmp[0].length + (tabIndex == -1 ? 1 : 0);
		  tabpos = (tabIndex == -1 ? 0 : tabIndex + 1) + tablen;
		  tabinc = 1;
	   }
   }else if(keyCode == 38) { // UP, doesn't work in NN
       if(!shistory[hispos]) {
	      if(document.myform["say"].value) hisadd();
		  hispos = shistory.length;
	   }
	   hispos--;
	   hisdo();
   }else if(keyCode == 40) { // DOWN, dito
       if(!shistory[hispos]) {
	      if(document.myform["say"].value) hisadd();
		  document.myform["say"].value = '';
		  return false;
	   }
	   hispos++;
	   hisdo();
   }else if(((event.altKey && !event.ctrlKey) || (!event.altKey && event.ctrlKey)) && charCode > 47 && charCode < 58) {
       // Alt or Ctrl + number is often bound to browser functions
       // Ctrl+Alt is totally equal to AltGr on Windows (strange!)
       // so use Ctrl+num or Alt+num, whatever the browser passes through
       var num = charCode - 48;
	   if(num == 0) num = 10;

	   var name = parent.fwindowlist.witemchgnum(num);
	   if(!name) return false;
	   parent.fwindowlist.witemchg(name);
   }else if(keyCode == 27) { // ignore escape (to stop..)
   }else{
       return true;
   }
   return false;
}

function pastedata(text) {
   var paste = text.split("\\n");
   if(paste.length == 1)
      return true;
   if(paste.length > 20) {
      alert("You can't paste more than 20 lines");
      return false;
   }

   if(paste.length < 5 ||
     confirm("Are you sure you want to paste " + paste.length + " lines?")) {
      parent.fwindowlist.sendcmd_real('paste', text, parent.fwindowlist.currentwindow);
      return false;
   }
}

//-->
</script>
<link rel="stylesheet" href="$config->{script_login}?interface=opera7&item=style&style=$cgi->{style}" />
</head>
<body onload="load()" onfocus="fns()" class="form-body">
<form name="myform" onSubmit="return cmd();" class="form-form">
<span id="nickname" class="form-nickname"></span>
<input type="text" class="form-say" name="say" autocomplete="off"
  onpaste="return pastedata(window.clipboardData.getData('Text',''));">
</form>
EOF
if($ENV{HTTP_USER_AGENT} !~ /Mac_PowerPC/ && (!exists $config->{disable_format_input} || !$config->{disable_format_input})) {
print <<EOF;
<span class="form-econtain" id="excont">
<input type="button" class="form-expand" onclick="t(document.getElementById('extra'),this);" value="&lt;&lt;">
<span id="extra" class="form-extra">
<input type="button" class="form-boldbutton" value="B" onclick="append('\%B')">
<input type="button" class="form-boldbutton" value="_" onclick="append('\%U')">
EOF
for(sort {$a <=> $b} keys %colours) {
   print "<input type=\"button\" style=\"background: $colours{$_}\" value=\"&nbsp;\" onclick=\"append('\%C$_')\">\n";
}
print <<EOF;
</span>
</span>
EOF
}
print <<EOF;
</body>
</html>
EOF
}

1;
