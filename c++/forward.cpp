/*
先给一句“白话版”的结论，再慢慢展开：

> **完美转发 = 把函数收到的参数，原封不动地“转交”给另一个函数，既不多加 const，也不错丢引用、右值性质。**

也就是：  
你怎么把东西给我，我就怎么再把它给下一个函数，**不改变它的“身份”**。

---

## 1. 为啥需要“完美转发”？

你经常会写“包装函数”/“中间层函数”，比如：

```cpp
void log_and_call(F f, ??? arg) {
    log();
    f(arg);  // 把参数转发给 f
}
```

但 `arg` 可能是：

- 普通变量（左值）
- 临时对象（右值）
- 带 const 的
- 引用
- …

如果你随便写成：

```cpp
void log_and_call(F f, T arg);          // 值传递
void log_and_call(F f, T& arg);         // 左值引用
void log_and_call(F f, const T& arg);   // const 左值引用
```

总有一些“性质”会丢掉，比如：

- 原来是右值（临时对象），你转发时变成了左值；
- 原来可修改，你传的时候变成 const；
- 原来是个很重的对象，你没用引用，结果拷贝了一份。

**完美转发就是为了避免这些损失：**

> 包装函数不“篡改”参数的类型/引用/右值特性，仅仅把它传下去。

---

## 2. 直观比喻

想象你是快递中转站：

- 用户给你一个包裹，有的特别注明“易碎品”“生鲜”“冷藏”“不要拆封”；
- 你的工作是转寄到下一个站。

**完美转发就是：**  
你不拆开、不换箱、不撕标签，按原样把包裹交给下家。

如果你不用完美转发，就好比：

- 把所有包裹拆开、换成普通纸箱、标签全撕了；
- 下一站收到的东西性质都变了：不知道哪个要冷藏、哪个易碎。

---

## 3. C++ 里是怎么做到的？（只讲直观，不讲标准术语）

C++ 提供两样东西配合使用：

1. `T&&` 泛型形参（模板里的“万能引用”，俗称 *forwarding reference*）  
   - 它能同时接住左值和右值：
     ```cpp
     template<typename T>
     void wrapper(T&& x);  // x 既能接左值，也能接右值
     ```

2. `std::forward<T>(x)`  
   - 这就是“完美转发”的关键工具；
   - 它会根据 `T` 的类型，把 `x` 用**原来的“左值/右值身份”**传下去。

典型模板写法：

```cpp
template <typename F, typename... Args>
void log_and_call(F&& f, Args&&... args) {
    log();
    std::forward<F>(f)( std::forward<Args>(args)... );
}
```

翻成人话就是：

- `Args&&... args`：无论你给我是左值还是右值，我都能接；
- `std::forward<Args>(args)...`：我再把它以**原本是左值就当左值，是右值就当右值**的方式转给 `f`。

---

## 4. “完美转发”解决了什么具体问题？

例子：

```cpp
void take_by_value(std::string s);       // 需要拷贝
void take_by_lvalue_ref(std::string& s); // 需要左值
void take_by_rvalue_ref(std::string&& s);// 需要右值
```

你写一个通用调用器：

```cpp
template<typename F, typename T>
void call(F&& f, T&& x) {
    f(x); // 这里没用 forward
}
```

问题：

- 如果 `x` 是右值，比如 `call(take_by_rvalue_ref, std::string("hi"));`  
  在 `call` 里，`x` 是一个**有名字的变量，一定是左值**；  
  你传 `f(x)`，相当于把一个左值传给 `T&&`，会匹配不到或产生额外拷贝。

改用完美转发：

```cpp
template<typename F, typename T>
void call(F&& f, T&& x) {
    f(std::forward<T>(x));  // 这里的 x 会“恢复”成原来的右值/左值身份
}
```

- 如果原来是右值，`std::forward` 会把它当右值传；
- 如果原来是左值，`std::forward` 会把它当左值传。

**这样才叫“完美”：包装层不改变参数的本质属性。**

---

## 5. 一句话再总结一遍

- 普通转发：  
  “你给我啥，我统一当普通变量用，再给下一家”——很多信息丢了。

- 完美转发：  
  “你给我啥，我带着它原本的标签（左值/右值、const 等）如实转交”——性能和语义都保留。

在 C++ 里，典型的“完美转发”代码模式就是：

```cpp
template<typename T>
void wrapper(T&& x) {
    callee(std::forward<T>(x));
}
```

如果你愿意，我可以再写一个完整可编译的小例子，展示“没用 forward”和“用了 forward”在行为和性能上的直观差别。
 */
#include <iostream>
#include <utility>
#include <string>

// 三个重载，用来区分是左值还是右值
void foo(const std::string& s) {
    std::cout << "foo(const std::string&):  接收到 **左值**\n";
}

void foo(std::string& s) {
    std::cout << "foo(std::string&):        接收到 **可修改左值**\n";
}

void foo(std::string&& s) {
    std::cout << "foo(std::string&&):       接收到 **右值**\n";
}

// ---------- 包装函数版本一：没有完美转发 ----------
template<typename T>
void call_without_perfect_forward(T&& x) {
    std::cout << "[call_without_perfect_forward]\n";
    foo(x);  // 注意：这里直接传 x，没有 std::forward
}

// ---------- 包装函数版本二：使用完美转发 ----------
template<typename T>
void call_with_perfect_forward(T&& x) {
    std::cout << "[call_with_perfect_forward]\n";
    foo(std::forward<T>(x));  // 用 std::forward 恢复原来的“左值/右值身份”
}

int main() {
    std::string s = "hello";

    std::cout << "\n=== 1. 直接调用 foo ===\n";
    foo(s);              // s 是左值
    foo(std::string("x")); // 临时对象，是右值

    std::cout << "\n=== 2. 通过不完美转发的 call_without_perfect_forward ===\n";
    call_without_perfect_forward(s);                  // 传左值
    call_without_perfect_forward(std::string("y"));   // 传右值

    std::cout << "\n=== 3. 通过完美转发的 call_with_perfect_forward ===\n";
    call_with_perfect_forward(s);                     // 传左值
    call_with_perfect_forward(std::string("z"));      // 传右值

    return 0;
}

