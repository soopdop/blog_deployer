---
layout: blog
title: '[Book Summary] 속깊은 Javascript 6/9'
date: 2017-06-29 18:35:01
categories:
- programming
tags:
- javascript, Book Summary
---

{% asset_img cover.jpg%} 

# Chapter 6. 브라우저 환경에서의 자바스크립트

## 6.1. 단일 스레드 환경
브라우저 환경의 가장 큰 특징은 Single thread 방식이라는 점이다. 자바스크립트 런타임은 처리해야 하는 요청을 순차적으로 처리하기 위해서 Queue(event queue/task queue, 이 책에서는 스레드 큐라는 용어를 사용하는데 맞는지 모르겠음.)를 사용한다.

### setTimeout(0)의 의미는?
setTimeout(0)은  "즉시, 메세지큐에 새로운 메세지를 등록하라"는 뜻이다. 역시 이책은 명확하게 정의하지 않는다. [이곳](""https://stackoverflow.com/questions/33955650/what-is-settimeout-doing-when-set-to-0-milliseconds/33955673")과 [이곳]("http://blog.carbonfive.com/2013/10/27/the-javascript-event-loop-explained/") 참고하여 setTimeout을 정의하면 다음과 같다.

> setTimeout(func,n)은 "n밀리초 후에 func를 큐에 등록하라"는 뜻이다. 

이렇게 하면 전담 스레드가 있어야 할 것 같은데.. 정확한 구현은 알 수 없지만 setTimeout 사이에 어떠한 많은 작업들이 들어갈 수 있으므로, 적어도 ***"메세지를 즉시 큐에 등록하고 n밀리초를 기다리라"***는 것은 절대 아니다.

따라서, setTimeout(0)은 즉시 메세지 큐에 메세지를 등록하지만 큐에 등록된 이전 작업의 시간에 따라서 실행 시점이 결정된다. 위의 정의가 맞다면, ```setTimeout(func1,1000)```, ```setTimeout(func2,2000)```, ```setTimeout(func3,3000)```를 실행 한 뒤 10초 걸리는 작업이 있다면, ```func1```/  ```func2```/```func3```은 1초 간격이 아니라 몰아서 실행되어야 한다. 
{%codeblock "setTimeout 실행 시점 테스트" lang:javascript%}
// 우선 setTimeout() 3를 실행한다.
var i = 0;
setTimeout(function() {console.log("func1 실행 시점: " + Date.now())}, 1000);
setTimeout(function() {console.log("func2 실행 시점: " + Date.now())}, 2000);
setTimeout(function() {console.log("func3 실행 시점: " + Date.now())}, 3000);

// 10초 딜레이
console.log("sleep 시작: " + Date.now());
var waitUntil = Date.now() + 10000;
while(Date.now() < waitUntil) {;}
console.log("sleep 끝: " + Date.now());
{%endcodeblock%}

결과: "10초 딜레이 후, setTimeout에 등록되었던 함수들은 1초 간격이 아니라, 한꺼번에 실행된다."
{%codeblock "" lang:text%}
sleep 시작: 1499216887137
sleep 끝: 1499216897137
func1 실행 시점: 1499216897143
func2 실행 시점: 1499216897143
func3 실행 시점: 1499216897144
{%endcodeblock%}

### setInterval()은 어떨까?

```setInterval```은 어떻게 정의해야할지 약간 난감하다. 다음 코드가 10초 전의 메세지들을 몰아서 실행하지 않고, 10초간의 sleep 중에는 전혀 메세지가 등록되지 않기 때문이다.

{%codeblock "setTimeout 실행 시점 테스트" lang:javascript%}
var i = 0;
setInterval(function() {
    console.log(""+(i++)+"번째 실행 시점: " + Date.now())
}, 2000);

    console.log("sleep 시작: " + Date.now());
var waitUntil = Date.now() + 10000;
while(Date.now() < waitUntil) {;}
console.log("sleep 끝: " + Date.now());
{%endcodeblock%}

```setInterval()```은 ```setTimeout()```과는 좀 다르게, 이전 ```func```가 실행되지 않고 큐에 쌓여있는 상태면 더이상 큐에 등록하지 않는다. 따라서 다음과 같이 정의할 수 있다.

> setInterval(func, n)은 "n밀리초 후에 func를 큐에 등록하라. 그리고 큐에 이전 func가 없을 때 반복하라."는 뜻이다. 

### (조사) setInterval()과 Recursive setTimeout()은 어떻게 다를까?
둘의 차이를 인지하고 필요한 곳에 사용해야 한다.

#### setInterval()의 시간 간격
시작 시간부터 일정 간격으로 호출하려고 시도한다. 그러나 작업이 길어져서 큐에 이전 작업이 들어있다면 그 시점은 건너 뛰고, 다음 시점에 실행한다. 
{%codeblock "" lang:javascript%}
let i = 1;
setInterval(function() {
  func(i);
}, 100);
{%endcodeblock%}

{% asset_img setinterval-interval.png "setInterval()의 간격" %}

#### Recurcive setTimeout()의 시간 간격
이 때는 func 안에서 다시 setTimeout()이 호출되는 시점으로부터 에서부터 다시 큐에 넣을 시간을 정한다.  

{%codeblock "" lang:javascript%}
let i = 1;
setTimeout(function run() {
  func(i);
  setTimeout(run, 100);
}, 100);
{%endcodeblock%}

{% asset_img settimeout-interval.png "Recurcive setTimeout()의 간격" %}

( 출처: https://javascript.info/settimeout-setinterval, http://jdm.kr/blog/97 )

## 6.2. requestAnimationFrame()
애니메이션을 그리기 위한 타이밍API이다. ```setInterval()``` 과 다른점은 UI를 다시 그려야할 경우가 아니라면 호출되지 않고, 모니터 주파수에 맞게 출력된다고 한다. 이처럼 성능면에서 좀 더 좋다고 한다.

{% jsfiddle m29tp6xq result,js,html dark %}

## 6.3. DOM과 자바스크립트

DOM은 'Document Object Model'의 약자로 HTML/XML 문서를 트리형태로 다루는 API이다. 

### 6.3.1. DOM repaint & reflow

이 책의 설명은 역시나 명확하지 않다. DOM repaint와 reflow의 차이는 다음과 같다.
- reflow : DOM node의 레이아웃 수치(높이, 위치)가 변경되어 랜더 트리를 재생성하는 과정이다. 전체 또는 부분 트리를 재생성해야 하므로 그 만큼 성능에 큰 영을 미침. 
- repaint : color/visibility 등의 스타일이 바뀔 때 다시 그리는 과정. reflow보다는 성능에 영향을 덜 미침.

이 [슬라이드]("https://www.slideshare.net/myposter_techtalks/how-browsers-work-74804349")를 보면 브라우저가 어떻게 랜더링을 하는지 잘 알수 있다. 요약하자면, 그림에서와 같이 브라우저는 렌더링을 위해서 DOM tree와 CSSOM tree 를 통해서 **Render tree**를 만들고, **layout**을 재구성한 뒤, **painting**을 하게 된다. 여기서의 **layout**이 reflow이다.

{% asset_img how_browers_work.png "브라우저의 렌더링 과정" %}

그리고, 크롬 개발자 도구 > performance > call tree를 보면 layout과 paint에 걸리는 시간을 확인할 수 있다.
 
{% asset_img call_tree.png "크롬 개발자 도구에서 본 call tree" %}

#### Reflow를 최소화 하는 몇가지 방법
몇가지 방법으로 reflow를 최소화 할 수 있다 한다.
1.  ```position:relative``` 컨터에너 안에 ```position:absolute``` 엘리멘트를 넣어서 reflow 영역 최소화. 
1. 태그명을 선택자로 스타일을 정의하는 것 보다 class나 id를 기반으로 스타일을 적용하는 것이 성능이 좋다.
1. 여러 개의 element를 추가 할때는 하나하나 추가하지 말고 아니라 ```DocumentFragment```를 이용하는 것이 좋다.
    - ```createDocumentFragment()``` 을 이용해서 가상의 DOM tree를 구성한 뒤, 최종적으로 ```appendChild()```로 실제 DOM tree에 추가하는 것이다.
1. 엘리멘트를 ```display:none``` 상태로 두고 조작한다.
1. ```offsetWidth```, ```clientHeight``` 등에 접근할 경우 reflow가 일어난다. 구글에서 **"layout thrashing"** 을 검색하면 많은 정보가 있다.  
    


### 6.3.3. DOM 탐색 횟수 최소화를 통한 성능 개선

memoization과 cache 등을 활용해서 getElementById를 최소화 한다. 

## 6.4. 웹 워커

### Web Worker

> Single thread 기반인 브라우저 환경을 개선하고자 도입된 개념이다.

낮은 버전의 브라우저는 지원하지 않는다.

### SharedWorker

> 다른 윈도우, iframe, web worker 등 다른 컨텍스트에서도 접근이 가능한 워커이다.