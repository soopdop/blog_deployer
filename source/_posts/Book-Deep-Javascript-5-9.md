---
layout: blog
title: '[Book Summary] 속깊은 Javascript 5/9'
date: 2017-06-29 18:34:55
categories:
- programming
tags:
- javascript, Book Summary
---

{% asset_img cover.jpg%} 

# Chapter 5. 디자인 패턴 실용
이 책에서는 자주 볼 수있는 유용한 패턴을 몇가지 소개하고 있다.

## 5.2. 모듈 패턴

> 소스를 모듈 단위로 관리하기 위해서 쓰이는 패턴이다. 대표적인 예로 jQuery의 ```$```를 들 수 있다.

{%codeblock "기본 틀" lang:javascript%}
(function (window) {
    var myLibrary = {
        method1 : function() {},
        method2 : function() {}
    }
    window.myLibrary = myLibrary // 글로벌 변수로 등록.
}(window));
{%endcodeblock%}

위와 같이 ```window``` 에 등록하는 방법, 아래와 같이 리턴을 받아서 할당하는 방법이 있다.

{%codeblock "리턴 받아서 글로벌 변수에 할당하기" lang:javascript%}
var myLibrary = (function () {
    return {
        method1 : function() {},
        method2 : function() {}
    }
}());
{%endcodeblock%}


## 5.2. 이벤트 델리게이션 패턴

이 책에서는 정의를 제대로 내리지 않고 유용한 상황을 먼저 설명하고 있다. 아래는 내가 정의한 이벤트 델리게이션이다.

> "이벤트 델리게이션 패턴이란 다수의 element에 각각에 event handler를 할당하는 것이 아니라, 그 것을 감싸는 부모 element에 하나의 event handler만 할당하여 처리하는 방식이다. 이 때, 조건문을 통해서 각 element의 이벤트를 처리한다." 

### (조사) 이벤트 버블링과 캡쳐링
이벤트 버블링과 캡쳐링은 이벤트가 전파되는 방향을 개발자가 설정하는 것이 아니다. 이미 브라우저는 특정 순서로 이벤트를 전파하고 있다. 이 때, 개발자가 부모와 자식 element에 각각 이벤트 핸들러를 등록해 두었을 경우, 브라우저가 전파하는 순서대로 그 이벤트 핸들러가 호출된다. 같은 element에 ```addEventListener(event, func1, true)```, ```addEventListener(event, func2, false)```로 capturing과 bubbling되는 이벤트를 처리할 수 있는 것은 w3c의 표준에 의해서 브라우저가 이미 두개의 흐름을 만들어 두었기 때문이다. 따라서 위와 같이 하나의 element에 capturing과 bubbling 이벤트 핸들러를 등록해 놓을 수 있고, 그렇이 하면 capturing으로 설정한 이벤트 핸들러인 func1이 먼저 호출된다. 그 이유는 다음에서 설명된다. 

#### (조사) 왜 버블링인가?
책에서는 자식 element로부터 부모 element로 이벤트가 전파되는 것을 버블링이라고 설명한다. 이 설명은 그냥 외우라는 것 그 이상 그 이하도 아니다. 한참을 찾은 끝에 [이 곳](https://www.kirupa.com/html5/event_capturing_bubbling_javascript.htm)에서 버블이라고 부르는 이유를 깨달을 수 있었다. 가장 헷갈렸던 부분은 bubble은 위로 올라가는데, 레이어의 순서를 기준으로 볼때 자식은 위쪽에 있기에 반대라고 생각했다. 하지만, 그 것 보다는 Tree를 생각해야 한다. HTML과 BODY를 최상위에 놓고 아래로 자식 element들을 트리 형태로 나열 한 그림을 놓고 볼때, 이벤트 버블링이 무엇인지 직관적으로 이해할 수 있다. 그 트리에서 가장 자식이 되는 element부터 최상위 부모까지 전달되며 버블처럼 올라가는 모습이 이벤트 버블링이다.   

#### (조사) 왜 캡쳐링인가?
열심히 검색해 봤으나 딱히 훌륭한 이유를 찾지는 못했다. 다만, 이벤트가 target으로부터 시작되는 버블링과는 달리, 어딘가로부터 시작된 이벤트가 여러 element를 거쳐 최종적으로 이벤트가 target으로 오게 되는 것으로 이해해 볼 수 있다. 즉 이벤트가 발생한 target element로부터 생겨난 버블이 뽀글뽀글 올라가는 것과는 정반대로, 최종적으로 target element로 가는 event를 그 조상(window,html,body)들이 가로채(capturing) 수 있다고 이해하면 될 것같다.  

#### (조사) 이벤트 캡처링과 버블링은 어떻게 동작하는가?
넷스케이프와 마이크로소프트가 각각 capturing과 bubbling방식 만을 지원했다. 하지만 W3C 표준에서는 두가지를 다 지원하도록 만들었다. 첫번째 단계에서는 capturing방식으로 이벤트를 전파하고, target에 도착한 뒤, bubbling방식으로 다시 이벤트를 전파한다. 

{% asset_img eventflow.png "Event flow" %}

아래 소스와 같이 capturing과 bubbling 둘 다를 처리하도록 만들고 테스트 해 보면, 전체 순서를 파악할 수 있다.    

{%codeblock "이벤트 캡처링과 버블링" lang:html%}
<style>
  body * {
    margin: 10px;
    border: 1px solid blue;
  }
</style>

<form>FORM
  <div>DIV
    <p>P</p>
  </div>
</form>

<script>
  for(let elem of document.querySelectorAll('*')) {
    elem.addEventListener("click", e => alert(`Capturing: ${elem.tagName}`), true);
    elem.addEventListener("click", e => alert(`Bubbling: ${elem.tagName}`));
  }
</script>
{%endcodeblock%}

#### 이벤트 델리게이션 예제
{% jsfiddle sa0e8L8q js,html,result dark %}

#### 그 밖에 이벤트 처리를 위해서 알아야 할 함수
##### e.stopPropagation()
위 예제에서 stopPropagation 함수는 그다지 쓸모가 없다. 다음과 같은 경우에 사용한다. 부모 element인 ```controlPanel```에 클릭이나 드래그를 할 수 있도록 만든다고 가정한다. 이 때, ```controlPanel```에 이벤트 핸들러를 할당한다면, 그 자식인 play 버튼을 눌러도 이벤트 버블링에 의해서 부모 element인 ```controlPanel```의 핸들러가 호출될 것이다. 이러한 상황을 막기 위해서 ```stopPropagation()```을  사용한다.
 
##### e.stopImmediatePropagation()
만약 하나의 target element에 두개 이상의 이벤트 핸들러가 할당되어 있을 경우, 할당한 순서대로 호출된다. 그런데 ```stopPropagation()```으로는 하위나 상위 element로의 이벤트 전달은 막을 수 있어도, 같은 엘리멘트에 등록되어있는 이벤트 핸들러의 호출은 막지 못한다. 이 때, 사용하는 것이  ```stopImmediatePropagation()```이다.

{% jsfiddle 8jg05urm js,html,result dark %}

##### e.preventDefault()
기본적으로 처리하는 이벤트를 막는다. 예를 들면, ```<a>```의 경우 클릭하면 특정 url로 이동하게 되어있다. ```<a>```가 다른 동작을 하도록 만들려면  ```preventDefault()``` 를 사용해야 한다.

## 5.3. 프락시 패턴
이 책은 직접적인 정의를 내리지 않고, **"X란 일반적으로 이런 것은 이런 곳에 쓰이는데, 이러한 것을 X라 한다."**는 패턴을 사용한다--; 자꾸 인터넷을 찾아봐야 하게 만드는 책이라는 생각이 든다. Javascript에서는 Proxy를 객체로 구현하여 사용하며, 다음의 Proxy 객체에 대한 나의 정의이다. 

> Javascript에서의 Proxy 객체는 특정 객체들의 인터페이스로써 이용되는 객체이다.

약간의 데코레이터 패턴과 그 모양새과 목적면에서 섞여 있는 듯하다. 다음과 같은 목적으로 사용할 수 있다.
1. 델리게이션 패턴 조합에 사용 
1. 캐시 기능 구현에 사용
1. http 요청의 제어에 사용
1. 래퍼 기능 구현에 사용


### "델리게이션 패턴 조합에 사용"
델리게이션 패턴을 구현할 때는 안쪽에 ```if``` 문을 사용해서 event와 target에 따른 분기를 해주는 것이 일반적인데, proxy 객체를 구현해서 좀 더 깔끔하게 만들 수 있다. 그리고 아래의 예제와 같이 구현하는 이유는 더 명확한 모듈화 가 가능하다는 이유에 인 것 같다. ```eventHandler```는 이벤트를 처리해주는 역할만 하고, ```proxy```는 중계자 역할, ```controllerObj``` 는 실제로 동작하는 루틴을 가진 객체이다. 

{% jsfiddle jy6g3btz js,html,result dark %}

### "캐시 기능 구현에 사용"
성능에 영향을 미치는 작업을 수행하는 객체에 대한 proxy객체를 만들어 캐시 기능을 구현할 때 쓰인다. 다음은 직접 작성한 예제. 

{%codeblock "" lang:javascript%}
var phoneBook = {
  searchUserByName(user) {
    // 성능에 영향을 미치는 작업
    return userInfo;
  }
};

var proxyPhoneBookForCache = {
  cache :  {},
  searchUserByName : function(value) {
    if (cache.hasOwnProperty(value)) {
      return cache[value];
    } else {
      cache[value] = phoneBook.searchUserByName(value);
      return cache[value];
    }
  }
}
{%endcodeblock%}

### http 요청의 제어에 사용
proxy를 이용하여 http요청을 한꺼번에 모아서 보내거나, 한번의 요청을 여러번의 요청으로 나누어 보내는 것이

{%codeblock "" lang:javascript%}

{%endcodeblock%}

## 5.4. 데코레이터 패턴
> 데코레이터란 특정 객체에 추가적인 기능을 동적으로 추가하는 패턴이다. 

### form validation을 위한 데코레이터
아래의 예제가 decorator pattern인지는 잘 모르겠다. 오히려 인터넷에서 찾은 [js pattern decorator](http://robdodson.me/javascript-design-patterns-decorator/)가 조금 더 명확한 것으로 보이나 확실하지는 않. 위 블로그에서는 기본 validator 객체에 ```decorate()```를 통해서 필요한 기능을 사용하겠다고 동적으로 선언했다. 그런데 이 예제에서는 ```decorate()```가 미리 정해진 규칙을 추가하는 용도로 쓰이기 때문에 좀 이상하다. 그래도 validator를 모듈화 하는데는 유용할 것으로 보인다.    

{% jsfiddle nkwegfxy js,html,result dark %}

### 객체 기반 데코레이터
자바를 기반으로 한 데코레이터 패턴은 다음 링크에 잘 나와있다(http://jusungpark.tistory.com/9) 아래의 예제에서도 ```Computer``` 객체를 ```decorate()```에 통과 시켜서 ***꾸며진 Computer**를 만들어 낸다. ```Decorator``` 객체는 각종 부품에 대한 정보를 관리하는 객체이며, 각 ```Computer```객체는 ```Decorator``` 객체로 부터 부품 정보를 이용한다. 이 패턴의 좋은 점은 특정 객체에서 부품 리스트를 관리한다는 것이고, 부품의 가격이 변한다 해도 그 것에 대한 레퍼런스를 가진 ```Computer``` 객체는 항상 최신 정보를 가질 수 있다는 것이다. 하지만, 그렇게 하려면, 굳이 들어있는 totlal price를 저장하는 부분을 없애야 할 것으로 보인. 

{% jsfiddle ujvaa6q7 js,result dark %}

### 함수 기반 데코레이터
객체가 가진 각 함수들을 꾸민다. before, after에 기능을 넣어 각 함수의 시작과 끝 시간을 보여준다. 

{% jsfiddle nmd7dfg2 js,result dark %}

## 5.5. init-time branching 패턴
> init-time branching이란 초기화 단계에서 분기하여 같은 함수를 환경에 따르게 다르게 정의하는 것을 의미한다. 

### addEventHandler와 removeEventHandler의 표준 호환성 지원

IE8 이하에서는 ```addEventListener```가 없다. 따라서 다음과 같이 ```attachEvent```를 통해서 구현할 수 있으며, 인터넷을 검색해 보면 관련하여 많은 정보가 나온다.

{%codeblock "표준 호환을 위한 이벤트 핸들러 함수 정의" lang:javascript%}
(function () {
    if (!Element.prototype.addEventListener) {
        if (Element.prototype.attachEvent) {
            Element.prototype.addEventListener = function (type, fn) {
                this.attachEvent("on" + type, fn);
            }
        } else {
            Element.prototype.addEventListener = function (type, fn) {
                this["on" + type] = fn;
            }
        }
    }

    if (!Element.prototype.removeEventListener) {
        if (Element.prototype.detachEvent) {
            Element.prototype.removeEventListener = function (type, fn) {
                this.detachEvent("on" + type, fn);
            }
        } else {
            Element.prototype.removeEventListener = function (type) {
                this["on" + type] = null;
            }
        }
    }
}());
{%endcodeblock%}

### XMLHttpRequest 객체 호환성 지원

과거의 IE는 ```XMLHttpRequest``` 표준 함수가 없어서 ```ActiveXObject```를 이용해야 했다. 이를 대비하여 브라우저에 맞는 ```getXHR()```을 리턴하는 패턴이다. 

{%codeblock "XMLHttpRequest 객체 호환성 지원" lang:javascript%}
function getXHR() {
    if (window.XMLHttpRequest) {
        return new XMLHttpRequest();
    }
    try {
        return new ActiveXObject("MSXML2.XMLHTTP.6.0");
    } catch (e) {
        try {
            return new ActiveXObject("MSXML2.XMLHTTP.3.0");
        } catch (e) {
            alert("This browser does not support XMLHttpRequest."); return null;
        }
    }
}
{%endcodeblock%}

## 5.6. Self-defining function 패턴

> 어떤 코드를 최초 한번만 실행되도록 하는 패턴을 말한다.

다음과 같은 코드로 함수 내부에서 자기 자신을 가리키는 참조 변수를 새로운 함수로 교체하는 방식으로 패턴을 구현한다. **"처음에만 어떤 것을 초기화"** 하거나, **"중복 호출되지 않도록 막는 기능"**을 구현할 때 유용하게 쓸 수 있다 글로벌 변수가 아닌 클로저를 사용할 수 있다.
{%codeblock "Self-defining" lang:javascript%}
// 글로벌 func 선언
var func = function() {
    console.log("The first.");
    // 한번 호출 뒤 글로벌 func가 변경됨.
    func = function() {
        console.log("The time after first.");
    }
}
func(); // The first
func(); // The time after first 
func(); // The time after first
{%endcodeblock%}

## 5.7. 메모이제이션(Memoization) 패턴

> 처리 시간이 필요한 작업을 "메모"해 두었다가, 나중에 사용하는 패턴.

즉, 메모리를 소모하는 대신 속도를 빠르게 하는 방법이라할 수 있다.
 
### 캐쉬 구현

{%codeblock "Memoization패턴을 이용한 cache 구" lang:javascript%}
(function(){
    function searchItem (id) { 
        // 이미 캐시에 있는 것이면 그냥 리턴한다.
        if(searchItem.cache.hasOwnProperty(id)) {
            return searchItem.cache[id];
        }
        // 캐시에 없으면 이 곳에서 http 서버로 부터 받아온다.   
    }    
    // 캐시 저장 공간
    searchItem.cache = {};
}());
{%endcodeblock%}

### 피보나치 구현
일반적으로 피보나치는 재귀함수로 구현한다. 아래와 같은 콜 트리가 만들어지게 된다. 하지만, 메모이제이션을 사용하면, 이미 한번 구한 값에 대해서는 또 계산을 하지 않기 때문에 훨씬 빠르다.

{% asset_img fibonacci.jpg %}

{%codeblock "Memoization패턴을 이용한 fibonacci 구현" lang:javascript%}
var fibonacci = (function () {
  var memo = [0, 1];
  var fib = function (n) {
      // 부분 결과를 저장해 둔다.
      var result = memo[n];
      // 부분 결과가 없을 때만 다시 호출한다. 
      if (typeof result !== 'number') {
        result = fib(n - 1) + fib(n - 2);
        memo[n] = result;
      }
      return result;
    };
  return fib;
}());
{%endcodeblock%}

### 메모이제이션을 위해 프로토타입 사용

아래와 같이 구현하면 메모이제이션을 일반화할 수 있으며, 그 것을 켜기 위해서 ```memoize()```를 호출한다.

{%codeblock "Memoization패턴 구현을 위해 포로토타입 사용" lang:javascript%}
(function () {
Function.prototype.memoize = function() {
  // 맴버함수 안에서의 this는 그 맴버를 가진 객체이다. 즉, 여기서는 fibonacci 함수.
  // memo는 클로저로 유지되는 변수. 그 안에 파라미터를 인덱스로 하여 부분 결과 데이터를 저장한다.     
  var _this = this,
    memo = {};
  return function() {
    var argsString = JSON.stringify(arguments),
      returnValue;
    if (memo.hasOwnProperty(argsString)) {
      // 이미 저장한 값이면 바로 리턴.
      return memo[argsString];
    } else {
      // 없는 값이면 fibonacci.apply() 후 저장하고 리턴.
      returnValue = _this.apply(this, arguments);
      memo[argsString] = returnValue;
      return returnValue;
    }
  }
};

function fibonacci(n) {
  if (n === 0 || n === 1) {
    return n;
  } else {
    return fibonacci(n - 1) + fibonacci(n - 2);
  }
}
var fibonacciMemo = fibonacci.memoize();
{%endcodeblock%}

## 5.8. Self-invoking constructor 패턴

> 실수로 new 키워드를 생략하더라도, 그 것을 붙여서 호출해주는 방어적인 패턴

앞 장에서 확인 했듯이 그냥 호출한 함수와 ```new```의 파라미터로 호출된 함수 안에서 ```this```가 가르키는 것은 다르다. 따라서, 생성자 함수를 ```new``` 없이 호출하면 전혀 의도 하지 않은 결과를 얻을 수 있다. 따라서 다음과 같이 내부에서 ```new```를 호출하도록 처리한다. 

{%codeblock "self-invoking constructor pattern" lang:javascript%}
(function() {
  function Employee(name, manMonth) {
    if (!(this instanceof Employee)) {
      // new 없이 호출 했을 때의 this는 window이다.
      return new Employee(name, manMonth);
    }
    // new로 호출 했을 때의 this는 새로 만들어진 객체이다.
    this.name = name;
    this.manMonth = manMonth;
  }
  var unikys = Employee("Unikys", 1),
    world = new Employee("World", 2);
  console.log(unikys);
  console.log(world);
}());
{%endcodeblock%}

```new``` 없이 호출 했을 때, 경고 메세지를 출력해 주면 좋을 것 같다.

## 5.9. 콜백 패턴

> 함수의 파라미터로에 해당 함수의 호출이 끝나고 나서 처리할 함수를 넘겨주는 패턴.
 
많이 쓰는 패턴으로 설명은 생략한다. 아래는 XMLHttpRequest를 jquery의 ajax함수 처럼 구현한 예제이다.

{%codeblock "callback" lang:javascript%}
(function() {
  function ajax(method, url, data, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url);
    xhr.onload = function() {
      if (xhr.status === 200) {
        callback.call(this, xhr.responseText);
      }
    }
    xhr.send(data);
  }
  ajax("POST", "/login", "id=hello&password=world", function(responseText) {
    if (responseText === "Success") {
      alert("Success to login!");
      ajax("GET", "/userInfo", "id=hello", displayUserInfo);
    } else {
      alert("Failed to login");
    }
  });

  function displayUserInfo(responseText) {
    document.getElementById("userInfo").innerHTML = responseText;
  }
}());
{%endcodeblock%}

## 5.10. 커링(Currying) 패턴

> 어떤 함수의 파라미터를 일부를 미리 채워두고, 나머지 파라미터만 입력 받는 새로운 함수를 만드는 패턴.

참고로 커링은 수학자 하스켈 커리(Haskell Curry)로 부터 유래되었다고 한다.
 
#### 간단한 커링
흔히 봤던 함수 저너레이터는 커링 패턴이라 볼 수 있다.

{%codeblock "simple currying" lang:javascript%}
(function () {
    // 원래의 함수
    function sum(x, y) {
        return x + y;
    }
    // 커링 함수
    var makeAdder = function (x) {
        return function (y) {
            return sum(x, y);
        };
    };
    // sum을 커링해서 adderFour가 나왔다.
    var adderFour = makeAdder(4);
    console.log(adderFour(1)); // === 5
    console.log(adderFour(5)); // === 9
}());
{%endcodeblock%}

#### 프로토타입을 이용한 일반화
{%codeblock "generalization of currying" lang:javascript%}
(function() {
  // 함수의 파라미터를 미리 설졍하는, 즉 currying을 해주는 함수.
  Function.prototype.curry = function() {
    // 파타미터가 0이면 그냥 this(원래 함수)를 리턴한다.
    if (arguments.length < 1) {
      return this;
    }
    // arguments를 클로저 변수에 함수, 파라미터를 저장한다.
    var _this = this,
      args = Array.prototype.slice.apply(arguments);
    return function() {
      // 저장해둔 파라미터들과 새로 받은 파라미터를 더해서 위에서 저장한 함수를 호출하는 클로저 함수를 리턴한다. 
      // 함수를 실행하는게 아니라 리턴한다.
      return _this.apply(this, args.concat(Array.prototype.slice.apply(arguments)));
    }
  }
  // 원래의 함수
  function sum(x, y) {
    return x + y;
  }
  // 원래의 함수에 커링을 적용한 함수를 리턴 받음.
  var adderFourCurry = sum.curry(4);
  console.log(adderFourCurry(5)); // === 9
  console.log(adderFourCurry(10)); // === 14
  // Function 프로토타입으로 일반화 하였으므로 이것도 가능함.
  function sum4(x, y, z, w) {
    return x + y + z + w;
  }
  var adderCurry = sum4.curry(5, 1);
  console.log(adderCurry(2, 3)); // === 11
}());

{%endcodeblock%}

#### 단위 변환 사용
다음과 같이 단위 변환을 위한 함수를 생성하는 것은 함수 저너레이터의 유용한 예제인듯 하다.

{%codeblock "unit conversion using currying" lang:javascript%}
(function() {
  // 위 예제와 같은 방법 사용.
  Function.prototype.curry = function() {
    if (arguments.length < 1) {
      return this;
    }
    var _this = this,
      args = Array.prototype.slice.apply(arguments);
    return function() {
      return _this.apply(this, args.concat(Array.prototype.slice.apply(arguments)));
    }
  }
  // 유닛 변환에 관한 파라미터들을 받고, 마지막으로 변환을 위한 input을 받는다.
  function unitConvert(fromUnit, toUnit, factor, input) {
    return `${input} ${fromUnit} === ${(input*factor).toFixed(2)} ${toUnit}`;
  }
  // 커링을 통해서 앞쪽의 3개의 파라미터를 채운 함수들을 리턴한다.
  var cm2inch = unitConvert.curry('cm', 'inch', 0.393701),
    metersquare2pyoung = unitConvert.curry('m^2', 'pyoung', 0.3025),
    kg2lb = unitConvert.curry('kg', 'lb', 2.204623),
    kmph2mph = unitConvert.curry('km/h', 'mph', 0.621371);
  // 결과.
  console.log(cm2inch(10)); // 10 cm === 3.94 inch
  console.log(metersquare2pyoung(30)); // 30 m^2 === 9.07 pyoung
  console.log(kg2lb(50)); // 50 kg === 110.23 lb
  console.log(kmph2mph(100)); // 100 km/h === 62.14 mph
}());
{%endcodeblock%}

#### XMLHttpRequest에 응용

커링을 이용해서 ajax함수를 get, put, post 등에 맞게 만들어서 사용할 수 있다.

{%codeblock "unit conversion" lang:javascript%}
(function() {
  // 역시 똑같은 방법.
  Function.prototype.curry = function() {
      if (arguments.length < 1) {
        return this;
      }
      var _this = this,
        args = Array.prototype.slice.apply(arguments);
      return function() {
        return _this.apply(this, args.concat(Array.prototype.slice.apply(arguments)));
      }
    }
    // ajax 함수 가장 앞의 파라미터로 method를 받는다.
  function ajax(method, url, data, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url);
    xhr.onload = function() {
      if (xhr.status === 200) {
        callback.call(this, xhr.responseText);
      }
    }
    xhr.send(data);
  }
  // 특정 method를 가진 ajax함수들을 생성할 수 있다.
  var ajaxGet = ajax.curry("GET"),
    ajaxPost = ajax.curry("POST"),
    ajaxPut = ajax.curry("PUT"),
    ajaxDelete = ajax.curry("DELETE");
  ajaxGet("/data", null, function(responseText) {
    console.log(responseText);
  });
}());    
{%endcodeblock%}