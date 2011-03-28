use strict;
use Test::More;
use Test::Exception;
use Fetch::WithStatic::Doc;

my $url = "http://d.hatena.ne.jp/sugyan/20110313/1300025780";
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
#use LWP::Simple qw/get/;
#my $content = get($url);
#use Encode;
#print encode_utf8($content);

my $data = join "\n", <DATA>;

#use Fetch::WithStatic::Util;
#my $util = Fetch::WithStatic::Util->new(
#    url => 'http://d.hatena.ne.jp/foobar',
#    dir => '.'
#);
my $doc = Fetch::WithStatic::Doc->new(content => $data, dir => '.', url => $url);

subtest "init" => sub {
    my $foo = 1;
    for my $static ($doc->download_queue) {
        ok $static->{file};
        ok $static->{localpath};
        like $static->{url}, qr{^https?};
    }
    done_testing;
};

subtest "self" => sub {
    my $self = $doc->self;
    isa_ok $self->{file}, "Path::Class::File";
    is $self->{basename}, "1300025780.html";
    ok $self->{localpath};
    ok $self->{path};

    done_testing;
};

subtest "as_html" => sub {
    my $html;
    my $doc = Fetch::WithStatic::Doc->new(content => $data, dir => '.', url => $url);
    lives_ok {
        $html = $doc->as_HTML;
    };
    like $html, qr{<html};
    my $tree = parse_html($html);

    my $check = sub {
        my %args = @_;
        my $name      = $args{name};
        my $selector  = $args{selector};
        my $attr_name = $args{attr_name};

        for my $elem (grep { $_->attr('fixed') } $tree->select($selector)) {
	        local $Test::Builder::Level = $Test::Builder::Level + 1;
            my $path = $elem->attr($attr_name);
            if ($name eq 'a') {
                like $path, qr/^https?/,   "a"   or note($path);
            }
            elsif ($name eq 'img') {
                like $path, qr/^static\//, "img" or note($path);
            }
            elsif ($name eq 'css') {
                like $path, qr/^static\//, "css" or note($path);
            }
            elsif ($name eq 'js') {
                like $path, qr/^static\//, "js"  or note($path);
            }
        }
    };
    $check->(name => 'a',   selector => 'a',      attr_name => 'href');
    $check->(name => 'css', selector => 'link',   attr_name => 'href');
    $check->(name => 'img', selector => 'img',    attr_name => 'src');
    $check->(name => 'js',  selector => 'script', attr_name => 'src');

    done_testing;
};

use HTML::TreeBuilder::Select;
sub parse_html {
    my $html = shift;
    my $tree = HTML::TreeBuilder::Select->new;
    $tree->parse($html);
    $tree->eof;
    $tree;
}
done_testing;

__DATA__
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html xmlns:og="http://ogp.me/ns#">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-jp">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<title>#prayforjapan を眺める - すぎゃーんメモ</title>
<link rel="start" href="/" title="すぎゃーんメモ">
<link rel="help" href="/help" title="ヘルプ">
<link rel="prev" href="/sugyan/20110310/1299724235" title="[Mac]github-growler appがSnow ...">
<link rel="next" href="/sugyan/20110315/1300119218" title="[node.js]続・ #prayforjapan を...">

<link rel="stylesheet" href="http://d.st-hatena.com/statics/css/base.css?3b8b4b5efaf96e4040fd78db70ec9dfcf8f2ddea" type="text/css" media="all">

<link rel="stylesheet" href="http://d.st-hatena.com/statics/theme/breeze/breeze.css?f2058efca5f0431d791c4a56ccfdaa8b5ad08d87" type="text/css" media="all">


<link rel="alternate" type="application/rss+xml" title="RSS" href="http://d.hatena.ne.jp/sugyan/rss">
<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://d.hatena.ne.jp/sugyan/rss2">

<link rel="meta" type="application/rdf+xml" title="FOAF" href="http://d.hatena.ne.jp/sugyan/foaf" />
<link rel="search" type="application/opensearchdescription+xml" href="http://d.hatena.ne.jp/sugyan/opensearch/diary.xml" title="すぎゃーんメモ内日記検索" />
<link rel="search" type="application/opensearchdescription+xml" href="http://d.hatena.ne.jp/sugyan/opensearch/archive.xml" title="すぎゃーんメモ内一覧検索" />


<link rel="shortcut icon" href="http://d.hatena.ne.jp/images/diary/sugyan/favicon.ico">



<style type="text/css">
<!-- 
pre { 
white-space: -moz-pre-wrap; /* Mozilla */  
white-space: -pre-wrap; /* Opera 4-6 */  
white-space: -o-pre-wrap; /* Opera 7 */  
white-space: pre-wrap; /* CSS3 */  
word-wrap: break-word; /* IE 5.5+ */  
font-size: medium;
}
-->
</style>




<meta property="og:type" content="article">
<meta property="og:title" content="#prayforjapan を眺める - すぎゃーんメモ">
<meta property="og:url" content="http://d.hatena.ne.jp/sugyan/20110313/1300025780">
<meta property="og:description" content="自粛しつつもコードでも書かないと落ち着かないわけで 世界中から #prayforjapan というタグで祈りを込めた..">
<meta property="og:site_name" content="はてなダイアリー">


<!--
<rdf:RDF
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:foaf="http://xmlns.com/foaf/0.1/">
<rdf:Description rdf:about="http://d.hatena.ne.jp/sugyan/20110313/1300025780">
   <foaf:maker rdf:parseType="Resource">
     <foaf:holdsAccount>
       <foaf:OnlineAccount foaf:accountName="sugyan">
         <foaf:accountServiceHomepage rdf:resource="http://www.hatena.ne.jp/" />
       </foaf:OnlineAccount>
     </foaf:holdsAccount>
   </foaf:maker>
</rdf:Description>
</rdf:RDF>
-->

<link rel="alternate" media="handheld" type="text/html" href="http://d.hatena.ne.jp/sugyan/mobile?date=20110313&section=1300025780" />
<!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:dc="http://purl.org/dc/elements/1.1/"
         xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/">
<rdf:Description
  rdf:about="http://d.hatena.ne.jp/sugyan/20110313/1300025780"
  trackback:ping="http://d.hatena.ne.jp/sugyan/20110313/1300025780"
  dc:title="[node.js]#prayforjapan を眺める"
  dc:identifier="http://d.hatena.ne.jp/sugyan/20110313/1300025780" />
</rdf:RDF>
-->

<script type="text/javascript" src="http://d.st-hatena.com/statics/js/MochiKit/1125/Base.js?649ee3542c7c6bbb389b28486494abb87dfe79fb"></script>
<script type="text/javascript" src="http://d.st-hatena.com/statics/js/MochiKit/1125/Iter.js?649ee3542c7c6bbb389b28486494abb87dfe79fb"></script>
<script type="text/javascript" src="http://d.st-hatena.com/statics/js/MochiKit/1125/DOM.js?649ee3542c7c6bbb389b28486494abb87dfe79fb"></script>
<script type="text/javascript" src="http://d.st-hatena.com/statics/js/MochiKit/1125/Style.js?649ee3542c7c6bbb389b28486494abb87dfe79fb"></script>
<script type="text/javascript" src="http://d.st-hatena.com/statics/js/MochiKit/1125/Signal.js?649ee3542c7c6bbb389b28486494abb87dfe79fb"></script>
<script type="text/javascript" src="http://d.st-hatena.com/statics/js/MochiKit/1125/Async.js?649ee3542c7c6bbb389b28486494abb87dfe79fb"></script>
<script type="text/javascript" src="http://d.st-hatena.com/statics/js/MochiKit/1125/Logging.js?649ee3542c7c6bbb389b28486494abb87dfe79fb"></script>
<script type="text/javascript" src="http://d.st-hatena.com/statics/js/BookmarkCommentViewer.js?649ee3542c7c6bbb389b28486494abb87dfe79fb" charset="utf-8"></script>






<script type="text/javascript" src="http://s.hatena.ne.jp/js/HatenaStar.js"></script>
<script type="text/javascript">
Hatena.Star.SiteConfig = {
  entryNodes: {
    'div.section': {
      uri: 'h3 a',
      title: 'h3',
      container: 'h3'
    }
  }
};
Hatena.Author  = new Hatena.User('sugyan');
Hatena.DiaryName  = new Hatena.User('sugyan');

</script>



<script type="text/javascript" src="http://d.st-hatena.com/statics/js/twitter_entry_icon.js?624193d7525aa17863f03b145a0662aa8bfba0bb"></script>



<script type="text/javascript" src="http://d.st-hatena.com/statics/js/adcolor.js?649ee3542c7c6bbb389b28486494abb87dfe79fb"></script>


<script type="text/javascript" src="http://d.st-hatena.com/statics/js/quick_pager.js?73e8efd3adc8709460b4c8ff9af5a3d4c97eba4e"></script>
<script type="text/javascript" src="http://d.st-hatena.com/statics/js/diary_utils.js?649ee3542c7c6bbb389b28486494abb87dfe79fb"></script>
<script type="text/javascript" src="http://d.st-hatena.com/statics/js/max_width_fotolife.js?649ee3542c7c6bbb389b28486494abb87dfe79fb"></script>












<script type="text/javascript" src="http://d.st-hatena.com/statics/js/jquery-1.4.2.min.js?1c983e39f64600478e5a829cf7a7a61f68527715"></script>
<script type="text/javascript">
  jQuery.noConflict()(function($){
    var j$ = jQuery;
  });
</script>




</head>
<body>

<table border="0" width="100%" cellspacing="0" cellpadding="0" id="banner">
<tr>
<td bgcolor="#FFFFFF" nowrap>
<a href="http://www.hatena.ne.jp/"><img border="0" src="http://d.hatena.ne.jp/images/hatena_wh.gif" width="104" height="40" alt="Hatena::"></a><a href="http://d.hatena.ne.jp/"><img border="0" src="http://d.hatena.ne.jp/images/diarywh.gif" width="60" height="40" alt="ブログ(Diary)"></a></td>
<td valign="bottom" align="left" bgcolor="#FFFFFF" width="60%" nowrap><form method="GET" action="/search" style="margin: 0;"><font color="#FFFFFF" size="2">&nbsp;&nbsp;<input type="text" name="word" value="" size="18" style="font-size: 8pt">&nbsp;<input type="hidden" name="name" value="sugyan"><input type="image" name="diary" alt="日記" src="http://d.hatena.ne.jp/images/search_diarywh.gif" align="top" style="width:34px;height:20px;border:0px">&nbsp;<input type="image" name="submit" alt="検索" src="http://d.hatena.ne.jp/images/searchwh.gif" align="top" style="width:34px;height:20px;border:0px"><br><img border="0" src="http://d.hatena.ne.jp/images/dot.gif" width="1" height="3" alt=""></font></form></td>
<td align="right" bgcolor="#FFFFFF"><a href="http://www.hatena.ne.jp/"><img border="0" src="http://d.hatena.ne.jp/images/hatenawh.gif" width="82" height="40" alt="はてな"></a></td>
</tr>
<tr>
<td width="100%" bgcolor="#999999" colspan="3"><img border="0" src="http://d.hatena.ne.jp/images/dot.gif" width="1" height="1" alt=""></td>
</tr>
<tr>
<td width="100%" bgColor="#ffffff" colspan="3">
<div align="center">
<center>
<table cellSpacing="0" cellPadding="2" width="100%" border="0">
<tbody>
<tr>
<td bgcolor="#FFFFFF" width="50%" nowrap><font color="#999999" size="2">&nbsp;ようこそゲストさん&nbsp;</font></td>
<td bgcolor="#FFFFFF" nowrap align="center"><a href="http://d.hatena.ne.jp/sugyan/" style="text-decoration:none; font-weight:100;"><font size="2" color="#999999">ブログトップ</font></a></td>
<td bgcolor="#FFFFFF" nowrap align="center"><a href="http://d.hatena.ne.jp/sugyan/archive" style="text-decoration:none; font-weight:100;"><font size="2" color="#999999">記事一覧</font></a></td>
<td bgcolor="#FFFFFF" nowrap align="center"><a href="https://www.hatena.ne.jp/login?backurl=http%3A%2F%2Fd.hatena.ne.jp%2Fsugyan%2F20110313%2F1300025780&add_timestamp=1" style="text-decoration:none; font-weight:100;"><font size="2" color="#999999">ログイン</font></a></td><td bgcolor="#FFFFFF" nowrap align="center"><a href="https://www.hatena.ne.jp/register?location=http://d.hatena.ne.jp/" style="text-decoration:none; font-weight:100;"><font size="2" color="#999999">無料ブログ開設</font></a></td>


</tr>
</tbody>
</table>
</center>
</div>
</td>
</tr>
<tr>
<td width="100%" bgcolor="#999999" colspan="3"><img border="0" src="http://d.hatena.ne.jp/images/dot.gif" width="1" height="1" alt=""></td>
</tr>
</table>



<h1><a href="http://d.hatena.ne.jp/sugyan/">すぎゃーんメモ</a> <a id="twitter-header-icon" href="http://twitter.com/sugyan"><img src="/images/icon-twitter.png" alt="Twitter" title="このページ作者のTwitterへ" border="0" width="16" height="16" class="icon"></a></h1>
<div class="hatena-body">
<div class="main">












<div class="calendar" id="pager-top">
  <a rel="prev" href="/sugyan/20110310/1299724235" class="prev">&lt;[Mac]github-growler appがSnow ...</a>&nbsp;<span class="delimiter">|</span>&nbsp;<a rel="next" href="/sugyan/20110315/1300119218" class="next">[node.js]続・ #prayforjapan を...&gt;</a><span id="edit-in-place-add"></span>
</div>
<div id="days">

<div class="day">
<h2><a href="http://d.hatena.ne.jp/sugyan/20110313"><span class="date">2011-03-13</span></a></h2>

<div class="body">

<!-- google_ad_section_start -->

		<div class="section">
			<h3 class="title"><a href="/sugyan/20110313/1300025780" name="1300025780">#prayforjapan を眺める</a></h3>
			<p class="sectionheader"><span class="sectioncategory"><a href="/sugyan/searchdiary?word=%2A%5Bnode%2Ejs%5D" class="sectioncategory">node.js</a></span></p>
			<p>自粛しつつも<a class="keyword" href="http://d.hatena.ne.jp/keyword/%A5%B3%A1%BC%A5%C9">コード</a>でも書かないと落ち着かないわけで</p>
			<p><a class="keyword" href="http://d.hatena.ne.jp/keyword/%C0%A4%B3%A6%C3%E6">世界中</a>から #prayforjapan という<a class="keyword" href="http://d.hatena.ne.jp/keyword/%A5%BF%A5%B0">タグ</a>で祈りを込めた<a class="keyword" href="http://d.hatena.ne.jp/keyword/%A5%E1%A5%C3%A5%BB%A1%BC%A5%B8">メッセージ</a>が<a class="keyword" href="http://d.hatena.ne.jp/keyword/Twitter">Twitter</a>や<a class="keyword" href="http://d.hatena.ne.jp/keyword/instagram">instagram</a>に<a class="keyword" href="http://d.hatena.ne.jp/keyword/%C5%EA%B9%C6">投稿</a>されている、という話をきいて、<a class="keyword" href="http://d.hatena.ne.jp/keyword/instagram">instagram</a>の<a class="keyword" href="http://d.hatena.ne.jp/keyword/%B2%E8%C1%FC">画像</a>をreal <a class="keyword" href="http://d.hatena.ne.jp/keyword/time">time</a> <a class="keyword" href="http://d.hatena.ne.jp/keyword/API">API</a>を使って受信して<a class="keyword" href="http://d.hatena.ne.jp/keyword/web">web</a>で<a class="keyword" href="http://d.hatena.ne.jp/keyword/%BC%AB%C6%B0">自動</a><a class="keyword" href="http://d.hatena.ne.jp/keyword/%B9%B9%BF%B7">更新</a>してくれるものを<a class="keyword" href="http://d.hatena.ne.jp/keyword/node%2Ejs">node.js</a>+socket.ioなどで作ってた。</p>
			<p><a href="http://sugyan.no.de/prayforjapan" target="_blank">http://sugyan.no.de/prayforjapan</a></p>
			<p>だいたい下記のような<a class="keyword" href="http://d.hatena.ne.jp/keyword/%A5%B3%A1%BC%A5%C9">コード</a>。</p>
			<p><script src="https://gist.github.com/866049.js?file=realtime.js"></script></p>
			<p><a class="keyword" href="http://d.hatena.ne.jp/keyword/%A5%B5%A1%BC%A5%D0">サーバ</a>は<a class="keyword" href="http://d.hatena.ne.jp/keyword/%A4%B5%A4%AF%A4%E9">さくら</a><a class="keyword" href="http://d.hatena.ne.jp/keyword/VPS">VPS</a>を節電のため落としたので先日joyentさんから<a class="keyword" href="http://d.hatena.ne.jp/keyword/%A5%A2%A5%AB%A5%A6%A5%F3%A5%C8">アカウント</a>いただいたno.deで動かしてる。</p>
			<p>socket.io <a class="keyword" href="http://d.hatena.ne.jp/keyword/client">client</a>からは自由に受信できるのでjsdo.itでも<a class="keyword" href="http://d.hatena.ne.jp/keyword/view">view</a>はできる</p>
			<p><script type="text/javascript" src="http://jsdo.it/blogparts/4foi/js?view=design"></script><p style="width: 465px; margin: 0; text-align: right; font-size: 11px;" class="ttlBpJsdoit"><a href="http://jsdo.it/sugyan/prayforjapan" title="prayforjapan">prayforjapan - jsdo.it - share JavaScript, HTML5 and CSS</a></p></p>
			<p>real <a class="keyword" href="http://d.hatena.ne.jp/keyword/time">time</a> <a class="keyword" href="http://d.hatena.ne.jp/keyword/API">API</a>が意外とイケてなくて<a class="keyword" href="http://d.hatena.ne.jp/keyword/TAG">TAG</a>の含まれる<a class="keyword" href="http://d.hatena.ne.jp/keyword/%B2%E8%C1%FC">画像</a>が<a class="keyword" href="http://d.hatena.ne.jp/keyword/%B9%B9%BF%B7">更新</a>された際にはその<a class="keyword" href="http://d.hatena.ne.jp/keyword/TAG">TAG</a>を教えてくれるだけでどの<a class="keyword" href="http://d.hatena.ne.jp/keyword/%B2%E8%C1%FC">画像</a>がupされたかは教えてくれないので結局<a class="keyword" href="http://d.hatena.ne.jp/keyword/API">API</a>を叩いて最新のものを取得してくるしかなかったりする。取得した<a class="keyword" href="http://d.hatena.ne.jp/keyword/%BE%F0%CA%F3">情報</a>は全部socket.ioに<a class="keyword" href="http://d.hatena.ne.jp/keyword/broadcast">broadcast</a>しているので<a class="keyword" href="http://d.hatena.ne.jp/keyword/client">client</a>側で重複<a class="keyword" href="http://d.hatena.ne.jp/keyword/%A5%D5%A5%A3%A5%EB%A5%BF%A5%EA%A5%F3%A5%B0">フィルタリング</a>する<a class="keyword" href="http://d.hatena.ne.jp/keyword/%BB%C5%CD%CD">仕様</a>にしてしまった。</p>
			<p>ともかく、祈りを込めた素敵な<a class="keyword" href="http://d.hatena.ne.jp/keyword/%B2%E8%C1%FC">画像</a>が次々と<a class="keyword" href="http://d.hatena.ne.jp/keyword/%C5%EA%B9%C6">投稿</a>されてくるのをみていると胸が熱くなる。<a class="keyword" href="http://d.hatena.ne.jp/keyword/%C0%A4%B3%A6">世界</a>の皆様、本当にありがとう。</p>
			<p class="share-button sectionfooter"><a href="http://b.hatena.ne.jp/entry/http://d.hatena.ne.jp/sugyan/20110313/1300025780" class="hatena-bookmark-button" data-hatena-bookmark-title="#prayforjapan を眺める" data-hatena-bookmark-layout="standard" title="このエントリーをはてなブックマークに追加"><img src="http://b.st-hatena.com/images/entry-button/button-only.gif" alt="このエントリーをはてなブックマークに追加" width="20" height="20" style="border: none;" /></a><script type="text/javascript" src="http://b.st-hatena.com/js/bookmark_button.js" charset="utf-8" async="async"></script><a href="http://twitter.com/share" class="twitter-share-button" data-lang="ja" data-count="none" data-url="http://d.hatena.ne.jp/sugyan/20110313/1300025780" data-text="#prayforjapan を眺める - すぎゃーんメモ (id:sugyan / @sugyan)">ツイートする</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js" charset="utf-8"></script><iframe src="http://www.facebook.com/plugins/like.php?href=http%3A%2F%2Fd.hatena.ne.jp%2Fsugyan%2F20110313%2F1300025780&amp;layout=button_count&amp;show_faces=false&amp;width=100&amp;action=like&amp;colorscheme=light&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:100px; height:21px;" allowTransparency="true"></iframe></p>

			<p class="sectionfooter"><a href="/sugyan/20110313/1300025780">Permalink</a> | <a href="/sugyan/20110313/1300025780#c">コメント(2)</a> | <a href="/sugyan/20110313/1300025780#tb">トラックバック(2)</a> | 23:16 <a href="http://b.hatena.ne.jp/entry/http://d.hatena.ne.jp/sugyan/20110313/1300025780" class="bookmark-icon"><img src="http://d.hatena.ne.jp/images/b_entry_wh.gif" border="0" title="#prayforjapan を眺めるを含むブックマーク" alt="#prayforjapan を眺めるを含むブックマーク" width="16" height="12" class="icon"></a> <img class="hatena-bcomment-view-icon" src="http://r.hatena.ne.jp/images/popup.gif" onclick="javascript:BookmarkCommentViewer.iconImageClickHandler(this, 'http://d.hatena.ne.jp/sugyan/20110313/1300025780', event);" title="#prayforjapan を眺めるのブックマークコメント" alt="#prayforjapan を眺めるのブックマークコメント" width="13" height="13"></p>

		</div>

<!-- google_ad_section_end -->

</div>

<form id="comment-form" method="post" action="/sugyan/comment#c" class="comment">
<input type="hidden" name="mode" value="enter">
<input type="hidden" name="rkm" value="">
<input type="hidden" name="date" value="2011-03-13">
<div class="comment">
  <div class="caption"><a name="c">コメントを書く</a></div>
  <div class="commentshort">
    
    
      <p>
        
                <a name="c113994914"></a><span class="commentator">
          <a href="/koba789/" class="hatena-id-icon"><img src="http://www.hatena.ne.jp/users/ko/koba789/profile_s.gif" class="hatena-id-icon" alt="koba789" title="koba789" height="16" width="16">koba789</a>
          
        </span>
        <span class="timestamp"><a name="c1300025910" href="/sugyan/20110313/1300025780#c1300025910">2011/03/13 23:18</a></span>
        <span class="commentbody">みなさん同じようなことをやっているのですね。<br>僕も http://koba789.com/ で地震情報をかき集めてます。</span>

      </p>
    
      <p>
        
                <a name="c113995021"></a><span class="commentator">
          <a href="/sugyan/" class="hatena-id-icon"><img src="http://www.hatena.ne.jp/users/su/sugyan/profile_s.gif" class="hatena-id-icon" alt="sugyan" title="sugyan" height="16" width="16">sugyan</a>
          
        </span>
        <span class="timestamp"><a name="c1300026495" href="/sugyan/20110313/1300025780#c1300026495">2011/03/13 23:28</a></span>
        <span class="commentbody">すごい勢いで流れてますね… 技術者流の素晴らしい貢献だと思います。ありがとうございます。</span>

      </p>
    

    <a name="error-message"></a>
    <p class="message" style="display:none"></p>

    

    
            
    <p class="commentform">
      <span class="commentator">
        <span class="usermailconfirm"><input name="usermail" size="1" value=""><input name="userurl" size="1" value="">スパム対策のためのダミーです。もし見えても何も入力しないでください<br></span>
        <span class="username">
        <img src="http://www.hatena.ne.jp/images/guest_icon.gif" class="hatena-id-icon" alt="ゲスト" title="ゲスト" height="16" width="16">
        <input type="hidden" name="section" value="1300025780">
        
          <input id="comment-username" name="username" size="15">
        
        </span>
        
          <span class="usermail"><img src="/images/icon-usermail.gif" style="vertical-align:middle;margin-right:3px;"><input id="comment-usermail" name="useremail" size="15" value=""></span>
          <span class="userurl"><img src="/images/icon-userurl.gif" style="vertical-align:middle;margin-right:3px;"><input id="comment-userurl" name="useruri" size="15" value=""></span>
        
      </span>
<br>
      <!-- NOT_VERIFIED_COMMENT_AUTH -->
      <textarea id="comment-textarea" name="body" value="" cols="60" rows="3"></textarea><br>
      
          <div class="captcha">
            <img src="/sugyan/captcha?1301278375" class="captcha-image">
            <span class="captcha-message">画像認証</span><br />
            <input type="text" name="captcha_code" size="10" class="captcha-string" id="comment-captcha">
          </div>
      
      <span class="comment-submit"><input type="submit" id="comment-form-button" value="投稿"></span>
    </p>

      <script type="text/javascript" src="/js/diary_comment_edit_form.js"></script>
    

  </div>
</div>

</form>





  
  <div class="refererlist">
    <div class="caption">
      <a name="tb">トラックバック</a> - http://d.hatena.ne.jp/sugyan/20110313/1300025780
    </div>
    
      
      <ul>
        
          <li>
            <a href="http://d.hatena.ne.jp/sugyan/20110315/1300119218" title=" 続・ #prayforjapan を眺める ようやく実家の両親とも電話が繋がるようになり、少し安心。あとは大船渡にいる親友の無事が確かめられれば良いのだけど… 祈りを込めて。 #prayforjapan を眺める - すぎゃーんメモから諸々変えた。 http://sugyan.no.de/prayforjapan 現時点" rel="nofollow">すぎゃーんメモ - 続・ #prayforjapan を眺める</a></li>
        
          <li>
            <a href="http://cside.g.hatena.ne.jp/Cside/20110315/p1" title=" http://d.hatena.ne.jp/sugyan/20110313/1300025780 をみながらnode.jsを復習。 var access_token = &amp;#39;XXXXXXXXXXXXXXXX&amp;#39;; var tag = &amp;#39;prayforjapan&amp;#39;; var http = require(&amp;#39;http&amp;#39;); var https = require(&amp;#39;https&amp;#39;); var socketIo = " rel="nofollow">雑記 - [javascript][node.js]作りながらnode.jsを復習</a></li>
        
      </ul>
    
  </div>
  
  








</div>



</div>
<div class="calendar" id="pager-bottom">
  <a rel="prev" href="/sugyan/20110310/1299724235" class="prev">&lt;[Mac]github-growler appがSnow ...</a>&nbsp;<span class="delimiter">|</span>&nbsp;<a rel="next" href="/sugyan/20110315/1300119218" class="next">[node.js]続・ #prayforjapan を...&gt;</a>
</div>
</div>
<div class="sidebar">
	<div class="hatena-module hatena-module-profile">
  <div class="hatena-moduletitle">プロフィール</div>
  <div class="hatena-modulebody">
    <div class="hatena-profile">
      <p class="hatena-profile-image"><a href="/sugyan/about"><img src="http://www.st-hatena.com/users/su/sugyan/user_p.gif" alt="sugyan" /></a></p>
      <p class="hatena-profile-id"><a href="/sugyan/about">sugyan</a></p>
      <p class="hatena-profile-body">perl -le ’print $~^” !#64:”’</p>
    </div>
  </div>
</div>

	<div class="hatena-module hatena-module-searchform">
<div class="hatena-moduletitle">日記の検索</div>
<div class="hatena-modulebody">
<form method="GET" action="/sugyan/searchdiary" class="hatena-searchform"><input type="text" name="word" class="hatena-searchform searchform-word" value=""><input type="submit" name=".submit" value="検索" class="hatena-searchform searchform-button"><br><label class="searchform-label-detail"><input type="radio" name="type" value="detail" checked="checked" class="searchform-radio">詳細</label> <label class="searchform-label-list"><input type="radio" name="type" value="list" class="searchform-radio">一覧</label></form>

</div>
</div>

	<div class="hatena-module hatena-module-calendar2">
<div class="hatena-moduletitle">カレンダー</div>
<div class="hatena-modulebody">
<table class="calendar" summary="calendar">
<tr>
<td class="calendar-prev-month" colspan="2"><a href="/sugyan/201102" title="201102" rel="nofollow">&lt;&lt;</a></td>
<td class="calendar-current-month" colspan="3"><a href="/sugyan/archive/201103" rel="nofollow">2011/03</a></td>
<td class="calendar-next-month" colspan="2"><a href="/sugyan/201104" title="201104" rel="nofollow">&gt;&gt;</a></td>
</tr>
<tr>
<td class="calendar-sunday">日</td>
<td class="calendar-weekday">月</td>
<td class="calendar-weekday">火</td>
<td class="calendar-weekday">水</td>
<td class="calendar-weekday">木</td>
<td class="calendar-weekday">金</td>
<td class="calendar-saturday">土</td>
</tr>
	<tr>
		<td class="calendar-day"></td>
		<td class="calendar-day"></td>
		<td class="calendar-day"><a href="/sugyan/20110301" title="1">1</a></td>
		<td class="calendar-day"><a href="/sugyan/20110302" title="2">2</a></td>
		<td class="calendar-day">3</td>
		<td class="calendar-day">4</td>
		<td class="calendar-day"><a href="/sugyan/20110305" title="5">5</a></td>
	</tr>
	<tr>
		<td class="calendar-day"><a href="/sugyan/20110306" title="6">6</a></td>
		<td class="calendar-day"><a href="/sugyan/20110307" title="7">7</a></td>
		<td class="calendar-day">8</td>
		<td class="calendar-day"><a href="/sugyan/20110309" title="9">9</a></td>
		<td class="calendar-day"><a href="/sugyan/20110310" title="10">10</a></td>
		<td class="calendar-day">11</td>
		<td class="calendar-day">12</td>
	</tr>
	<tr>
		<td class="calendar-day day-selected"><a href="/sugyan/20110313" title="13">13</a></td>
		<td class="calendar-day">14</td>
		<td class="calendar-day"><a href="/sugyan/20110315" title="15">15</a></td>
		<td class="calendar-day"><a href="/sugyan/20110316" title="16">16</a></td>
		<td class="calendar-day">17</td>
		<td class="calendar-day">18</td>
		<td class="calendar-day">19</td>
	</tr>
	<tr>
		<td class="calendar-day"><a href="/sugyan/20110320" title="20">20</a></td>
		<td class="calendar-day"><a href="/sugyan/20110321" title="21">21</a></td>
		<td class="calendar-day">22</td>
		<td class="calendar-day">23</td>
		<td class="calendar-day"><a href="/sugyan/20110324" title="24">24</a></td>
		<td class="calendar-day"><a href="/sugyan/20110325" title="25">25</a></td>
		<td class="calendar-day">26</td>
	</tr>
	<tr>
		<td class="calendar-day">27</td>
		<td class="calendar-day day-today">28</td>
		<td class="calendar-day">29</td>
		<td class="calendar-day">30</td>
		<td class="calendar-day">31</td>
		<td class="calendar-day"></td>
		<td class="calendar-day"></td>
	</tr>
</table>
	</div>
</div>

	<div class="hatena-module hatena-module-sectioncategory">
<div class="hatena-moduletitle">カテゴリー</div>
<div class="hatena-modulebody">
<ul class="hatena-sectioncategory">
<li><a href="/sugyan/searchdiary?word=%2A%5Bdiary%5D">diary</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BJava%5D">Java</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BLinux%5D">Linux</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BBook%5D">Book</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BFirefox%5D">Firefox</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BSQL%5D">SQL</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BEmacs%5D">Emacs</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BPerl%5D">Perl</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BCGI%5D">CGI</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BJavaScript%5D">JavaScript</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BMySQL%5D">MySQL</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BWeb%5D">Web</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BMac%5D">Mac</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BSubversion%5D">Subversion</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BMemo%5D">Memo</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BPython%5D">Python</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BTwitter%5D">Twitter</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BSaichugen%5D">Saichugen</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BObjective%2DC%5D">Objective-C</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BiPhone%5D">iPhone</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BLightningTalks%5D">LightningTalks</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5B%CA%D9%B6%AF%B2%F1%5D">勉強会</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BBash%5D">Bash</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BWassr%5D">Wassr</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BRuby%5D">Ruby</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BPHP%5D">PHP</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BOneLiner%5D">OneLiner</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BGoogleAppEngine%5D">GoogleAppEngine</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BZsh%5D">Zsh</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BEclipse%5D">Eclipse</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BGit%5D">Git</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BGolf%5D">Golf</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BGoogleWave%5D">GoogleWave</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BIRC%5D">IRC</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BActionScript%5D">ActionScript</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5Bwonderfl%5D">wonderfl</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BCSS%5D">CSS</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BHTML5%5D">HTML5</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5Bjsdoit%5D">jsdoit</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BArk%5D">Ark</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5BFacebook%5D">Facebook</a></li>
<li><a href="/sugyan/searchdiary?word=%2A%5Bnode%2Ejs%5D">node.js</a></li>
</ul>
</div>
</div>

	<div class="hatena-module hatena-module-section">
<div class="hatena-moduletitle"><a href="/sugyan/archive">最新タイトル</a></div>
<div class="hatena-modulebody">
<ul class="hatena-section">
<li><a href="http://d.hatena.ne.jp/sugyan/20110325/1301061279">[Perl][node.js]qunit-tapを使ってnode.jsのテストをproveで行う</a></li>
<li><a href="http://d.hatena.ne.jp/sugyan/20110325/1301046215">nginxのHttpLimitReqModuleについて</a></li>
<li><a href="http://d.hatena.ne.jp/sugyan/20110324/1300970887">[JavaScript][node.js]東京Node学園 1時限目 メモ</a></li>
<li><a href="http://d.hatena.ne.jp/sugyan/20110321/1300641998">[JavaScript]JavaScriptで住所入力支援 その2</a></li>
<li><a href="http://d.hatena.ne.jp/sugyan/20110320/1300630123">支援のお願い</a></li>
<li><a href="http://d.hatena.ne.jp/sugyan/20110320/1300559614">[JavaScript]JavaScriptで住所入力支援</a></li>
<li><a href="http://d.hatena.ne.jp/sugyan/20110316/1300272186">[Mac][Perl][diary]半自動</a></li>
<li><a href="http://d.hatena.ne.jp/sugyan/20110316/1300201475">[JavaScript][jsdoit]instagram #prayforjapan map</a></li>
<li><a href="http://d.hatena.ne.jp/sugyan/20110315/1300179627">[diary]人間のチカラ</a></li>
<li><a href="http://d.hatena.ne.jp/sugyan/20110315/1300119218">[node.js]続・ #prayforjapan を眺める</a></li>
</ul>
</div>
</div>

	<div class="hatena-module hatena-module-comment">
<div class="hatena-moduletitle">最近のコメント</div>
<div class="hatena-modulebody">
<ul class="hatena-recentcomment">
<li><a href="/sugyan/20110321/1300641998#c">2011-03-21</a>&nbsp;sugyan</li>
<li><a href="/sugyan/20110321/1300641998#c">2011-03-21</a>&nbsp;tmatsuu</li>
<li><a href="/sugyan/20110320/1300630123#c">2011-03-20</a>&nbsp;sugyan</li>
<li><a href="/sugyan/20110320/1300630123#c">2011-03-20</a>&nbsp;ひきっちー</li>
<li><a href="/sugyan/20110320/1300630123#c">2011-03-20</a>&nbsp;sugyan</li>
</ul>
</div>
</div>

	<div class="hatena-module hatena-module-trackback">
<div class="hatena-moduletitle">最近のトラックバック</div>
<div class="hatena-modulebody">
<ul class="hatena-recentcomment">
<li><a href="/sugyan/20110325#tb">2011-03-25</a>&nbsp;<a href="http://twitter.com/matsu911/status/51446753580417024">Twitter / @matsu911</a></li>
<li><a href="/sugyan/20110325#tb">2011-03-25</a>&nbsp;<a href="http://twitter.com/t_wada/status/51436405490073600">Twitter / @t_wada</a></li>
<li><a href="/sugyan/20110324#tb">2011-03-24</a>&nbsp;<a href="http://twitter.com/ryu22e/status/50933477255823360">Twitter / @ryu22e</a></li>
<li><a href="/sugyan/20090114/1231862974#tb">2009-01-14</a>&nbsp;<a href="http://d.hatena.ne.jp/sir_kgi/20110322/1300803641">トライ＆エラー／TRY &amp; ERROR - メモ</a></li>
<li><a href="/sugyan/20110307/1299508206#tb">2011-03-07</a>&nbsp;<a href="http://d.hatena.ne.jp/gfx/20110321/1300720684">Islands in the byte stream -  忙しい人のための「新卒準備カレン...</a></li>
</ul>
</div>
</div>

        <div class="hatena-module hatena-module-keywordcloud">

<div class="hatena-moduletitle"><a href="/sugyan/keywordcloud">最近言及したキーワード</a></div>

<div class="hatena-modulebody">
<ul class="keywordcloud">

<li><a href="/sugyan/searchdiary?word=API" class="keywordcloud4">API</a></li>

<li><a href="/sugyan/searchdiary?word=CSS" class="keywordcloud4">CSS</a></li>

<li><a href="/sugyan/searchdiary?word=Finder" class="keywordcloud0">Finder</a></li>

<li><a href="/sugyan/searchdiary?word=HTML5" class="keywordcloud4">HTML5</a></li>

<li><a href="/sugyan/searchdiary?word=JSON" class="keywordcloud2">JSON</a></li>

<li><a href="/sugyan/searchdiary?word=JavaScript" class="keywordcloud10">JavaScript</a></li>

<li><a href="/sugyan/searchdiary?word=client" class="keywordcloud0">client</a></li>

<li><a href="/sugyan/searchdiary?word=%A4%B7%A4%A4" class="keywordcloud2">しい</a></li>

<li><a href="/sugyan/searchdiary?word=%A5%B5%A1%BC%A5%D0" class="keywordcloud4">サーバ</a></li>

<li><a href="/sugyan/searchdiary?word=%A5%B9%A5%AF%A5%EA%A5%D7%A5%C8" class="keywordcloud2">スクリプト</a></li>

<li><a href="/sugyan/searchdiary?word=%A5%C7%A1%BC%A5%BF" class="keywordcloud2">データ</a></li>

<li><a href="/sugyan/searchdiary?word=%A5%D5%A5%A1%A5%A4%A5%EB" class="keywordcloud2">ファイル</a></li>

<li><a href="/sugyan/searchdiary?word=%B2%E8%C1%FC" class="keywordcloud2">画像</a></li>

<li><a href="/sugyan/searchdiary?word=%B7%EB%B2%CC" class="keywordcloud2">結果</a></li>

<li><a href="/sugyan/searchdiary?word=%B8%A1%BA%F7" class="keywordcloud4">検索</a></li>

<li><a href="/sugyan/searchdiary?word=%B9%B9%BF%B7" class="keywordcloud2">更新</a></li>

<li><a href="/sugyan/searchdiary?word=%BC%AB%C6%B0" class="keywordcloud2">自動</a></li>

<li><a href="/sugyan/searchdiary?word=%BE%F0%CA%F3" class="keywordcloud2">情報</a></li>

<li><a href="/sugyan/searchdiary?word=%C5%EA%B9%C6" class="keywordcloud2">投稿</a></li>

<li><a href="/sugyan/searchdiary?word=%C6%FE%CE%CF" class="keywordcloud2">入力</a></li>

</ul>
</div>
</div>

        <script language="javascript" type="text/javascript" src="http://b.hatena.ne.jp/js/widget.js" charset="utf-8"></script>
<script language="javascript" type="text/javascript" src="http://b.hatena.ne.jp/js/widget.js" charset="utf-8"></script>
<script language="javascript" type="text/javascript">
Hatena.BookmarkWidget.url   = "http://d.hatena.ne.jp/sugyan/";
Hatena.BookmarkWidget.title = "人気エントリー";
Hatena.BookmarkWidget.sort  = "count";
Hatena.BookmarkWidget.width = 0;
Hatena.BookmarkWidget.num   = 5;
Hatena.BookmarkWidget.theme = "hatenadiary";
Hatena.BookmarkWidget.load();
</script>	        <div class="hatena-module hatena-module-pv">
                <div class="hatena-moduletitle">ページビュー</div>
                <div class="hatena-modulebody">
                        <span class="hatena-counter">598862</span>
                </div>
        </div>

	<div style="width:176px;text-align:center"><embed src="http://twitter.com/flash/twitter_badge.swf"  flashvars="color1=10027008&type=user&id=15081480"  quality="high" width="176" height="176" name="twitter_badge" align="middle" allowScriptAccess="always" wmode="transparent" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" ></embed><br><a href="http://twitter.com/sugyan" style="font-size: 10px; color: #990000; text-decoration: none">follow sugyan at http://twitter.com</a></div>
	<script type="text/javascript" src="http://wassr.jp/js/WassrBlogParts.js"></script><script type="text/javascript">wassr_host = "wassr.jp";wassr_userid = "sugyan";wassr_defaultview = "";wassr_bgcolor="1D6E13";wassr_titlecolor="B5FFAD";wassr_textcolor="";wassr_boxcolor="BCC6B6";WassrFlashBlogParts();</script>
	<a href="http://tophatenar.com/view/sugyan"><img width="160" src="http://tophatenar.com/chart/bookmark_small/sugyan" height="120"></a>
</div>
</div>






<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(
  ['_setAccount', 'UA-441387-31'],
  ['_trackPageview'],
  ['b._setAccount', 'UA-7855606-1'],
  ['b._setDomainName', '.hatena.ne.jp'],
  ['b._trackPageview']
  ,['c._setAccount', 'UA-4641008-1'],
  ['c._trackPageview']
  );
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
<!-- CG:1,CH:0,ICG:13,ICH:3 -->
</body>
</html>

