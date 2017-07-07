---
layout: blog
title: '[Book Summary] 속깊은 Javascript 7/9'
date: 2017-06-29 18:35:11
categories:
- Book Summary
tags:
- javascript
---

{% asset_img cover.jpg%}
 
# Chapter 7. 자바스크립트 성능과 사용자 경험 개선

## 7.1. ```<script>``` 태그위치와 레이지 로드

### ```<script>``` 태그위치
```<script>```는 block mode로 작동한다. script가 다 실행 될때까지 화면이 렌더링 되지 않는다. 그 이유는 ```document.write()```로 html을 쓸 수도 있기 때문이라 한다. 따라서 ```<script>``` 태그는 html 문서의 가장 아래 쪽에 위치하는 것이 좋다.

### Lazy Load For Script File
위와 같은 blocking현상을 막기 위해서 lazy load를 구현하는 것이다. lazy load의 구현은 구현 방법은 ```window.attachEvent("onload")```와 ```window.addEventListener("load")```를 이용해서 다음과 같이 구현한다.
 
{%codeblock "Script Lazy Load" lang:javascript%}
(function() {
  var previousOnload;
  if (window.addEventListener) {
    window.addEventListener("load", lazyload);
  } else if (window.attachEvent) {
    window.attachEvent("onload", lazyload);
  } else if (window.onload) {
    // addEventListener와 attachEvnet가 없으면 onload로 구현하되,
	  // 이미 등록된 이벤트 핸들러를 백업해두었다가 나중에 같이 호출함.
    previousOnload = window.onload;
    window.onload = function() {
      previousOnload.call();
      lazyload();
    }
  } else {
  	// onload에 등록된 것도 없으면 그냥 할당.
    window.onload = lazyload; // this can be overwritten by another JS
  }

  function lazyload() {
    // 새로운 script 태그를 만들고, 속성을 설정
    var scriptTag = document.createElement("script"),
      headTag = document.getElementsByTagName("head")[0];
    scriptTag.setAttribute("src", "./sleep.js");
    scriptTag.setAttribute("type", "text/javascript");
    scriptTag.setAttribute("async", "true");
    // way around if there is no head tag
    if (!headTag) {
      headTag = document.getElementsByTagName("script")[0].parentNode;
    }
    // DOM에 추가
    headTag.appendChild(scriptTag);
  }
}());

{%endcodeblock%}

```window.onload``` 를 이용할 수 있지만, 이 방식은 다수의 이벤트 핸들러를 등록하지 못하므로 기존에 등록되어 있던 것을 다 덮어 써버릴 염려가 있다. 

### Lazy Load For Image File

우선 다음과 같이 ```class``` 명을 주고, ```src```는 ```data-src```로 준다. 중요한 점은 ```width```와 ```height``` 속성을 태그에 미리 주어서 자리차지를 하고 있는 것이 미관 좋다. 하지만, 모든 ```img``` 태그에 ```width```와 ```height```를 주는 것도 그렇게 좋은 방법은 아닌 것으로 보이므로 상황에 따라 잘 판단해야 할듯. 
{%codeblock "lazy load를 위한 img태그" lang:html%}
<body>
  <img width="640" height="480" class="lazyload" data-src="./large_image.jpg" />
  <img width="64" height="64" class="lazyload" data-src="./not_important_image.jpg" />
</body>
{%endcodeblock%}

스크립트에서는 각 ```img``` 태그의 ```data-src```를 ```src```로 변경해주면 된다. 

{%codeblock "lazy load를 위한 script" lang:javascript%}
(function() {
  var previousOnload;
  if (window.addEventListener) {
    window.addEventListener("load", lazyloadImages);
  } else if (window.attachEvent) {
    window.attachEvent("onload", lazyloadImages);
  } else if (window.onload) {
    previousOnload = window.onload;
    window.onload = function() {
      previousOnload.call();
      lazyloadImages();
    }
  } else {
    window.onload = lazyloadImages; // this can be overwritten by another JS
  }

  // lazyload 클래스를 가진 element를 찾아서 data-src를 src로 바꾸어 주면 끝.
  // 단, 이곳에 방어코드와 예외처리는 좀 더 필요할 것 같다.
  function lazyloadImages() {
    var imgList = document.getElementsByClassName("lazyload"),
      length = imgList.length,
      i;
    for (i = 0; i < length; i++) {
      imgList[i].src = imgList[i].getAttribute("data-src");
    }
  }
}());
{%endcodeblock%}

### "Loading" 아이콘 보이기
돌아가는 모습의 애니메이션을 넣기 위해서는 loading.gif를 준비하고 다음과 같은 css를 모든 ```img```에 적용한다.
{%codeblock "CSS for lazy loading image" lang:css%}
.lazyload {
  background-image: url("./loading.gif");
  background-size: 64px 64px;
  background-repeat: no-repeat;
  background-position: center;
}
{%endcodeblock%}

그 후, ```lzayloadImages()```에서는 class를 변경하거나 createElement로 진 ```img```를 만들어서 ```replaceChild``` element를 교체 한다.

## 7.2. 인터넷 환경에서의 HTTP GET 최적화
HTTP GET의 횟수를 줄이거나, 다운로드 되는 크기를 줄이는 것이 사용자 경험을 개선하는데 가장 효과적인 방법이라고 한다. 

### 7.2.1. 소스 미니피케이션으로 GET 용량 최소화
minification을 통해서 소스의 다운로드 크기를 크게 줄일 수 있다. 이렇게 해주는 툴은 [YUI compressor]("http://yui.github.io/yuicompressor/"), [Google Closure complier]("https://developers.google.com/closure/compiler/"), [JSMin]("http://crockford.com/javascript/jsmin") 등이 있다

### 7.2.2. 파일을 압축해서 GET 용량 최소화
더 조사해 봐야 하지만, 서버와 클라이언트는 [Content negotiation]("https://developer.mozilla.org/ko/docs/Web/HTTP/Content_negotiation") 과정을 거쳐서 동일한 URI에 대해서 여러가지 타입의 리소스를 주고 받을 수 있다. 

{% asset_img HTTPNegoServer.png "HTTP Content negotitiation" %}

클라이언트는 서버로 요청을 보낼 시 ```Accept-*``` 헤더에 원하는 타입을 나열하여 서버로 요청을 보내고, 서버는 ```Content-*```에 컨텐트의 타입을 명시하여 응답하는 방식이다. ```Accept-Encoding```헤더에 gzip 또는 deflate를 넣어서 보내면 서버는 응답에 압축된 데이터를 넣어서 보내준다. 

책에서는 아파치가 압축을 제공하기 위한 설정 방법에 대해서 설명하고 있지만, 딱히 기억해야할 만한 것은 아니다.  

### 7.2.3. GET 요청 횟수 최소화(파일 합치기)
다운로드 크기를 최소화 하는 방법 외에 요청의 횟수 자체를 줄여 서버의 부담을 덜 수 있다. 

### Script 파일 합치기
다수의 js파일을 로딩할 경우 다수의 ```<script>```를 서버로 요청한다. 이 것을 하나로 줄이기 위해서 서버에 배포하기 전, 추가적인 빌드 과정을 통해서 js파일을 하나로 합치고, 더불어 압축하거나 미니피케이션까지 수행하기도 한다. 이렇게 하는 것에는 장단점이 있다.
 
1. 장점
    - 요청/응답 횟수의 최소화.
    - gzip 등의 압축 처리를 한번에 할 수 있음.
1. 단점
    - 추가적인 빌드 과정이 필요함.
    - 부분 수정이 있을 경우, 캐시 효율이 떨어짐.

#### 주의할 점
각 js 파일에서 전역 "use strict"를 사용할 경우 문제가 발생할 수 있으니, local strict 모드를 사용하는 것이 좋다.

{%codeblock "CSS for lazy loading image" lang:css%}
(function(){}(
    "use strict"
    // 생략
));
{%endcodeblock%}


### Image 파일 합치기
Sprite Image를 사용하여 하나의 이미지를 받은 후 잘라서 사용하는 방식이다. 특히 아이콘과 같은 작은 이미지를 많이 사용할 때, 각각을 서버로 요청하는 대신 한번의 요청으로 많은 이미지를 받을 수 있다는 장점이 있다.

{%codeblock "sprite image" lang:html%}
<style>
  .flag {
    background-image: url("flags.png");
    background-size: 20px auto;
    width: 20px;
    height: 13px;
  }
  .en {
    background-position: 0px -12px;
  }
  .cn {
    background-position: 0px -23px;
  }
  .jp {
    background-position: 0px -38px;
  }
</style>
<a><img class="flag ko"></img>Korean</a>
<a><img class="flag en"></img>English</a>
<a><img class="flag cn"></img>Chinese</a>
<a><img class="flag jp"></img>Japanese</a>
{%endcodeblock%}

위 소스와 같이 ```img```태그에 ```src```를 설정하는 것이 아니라, 스타일에 ```background-image```를 설정하고 각 이미지 마다 ```background-position```을 다르게 설정하여 사용하고 있다.  

### 7.2.4. Cache 설정

1. Expires 헤더
    - 특정 요청의 응답에 Expire time을 지정하면 그 시간이 되기 전까지 브라우저는 cache로부터 데이터를 가져다 쓴다. 하지만 웹페이지 변경 시 업데이트가 되지 않을 수 있는 문제가 있다.
1. ETag 헤더
    - 일종의 해쉬이다. 클라이언트는 특정 요청에 대한 ETag 값을 보내면, 서버도 해당 요청의 최신 ETag와 비교해서 같다면, ```HTTP 304 Not Modified``` 응답을 보낸다. 그러면 클라이언트는 cache를 사용한다.   
