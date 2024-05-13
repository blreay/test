#include <iostream>
#include <vector>

using namespace std;

// 交换两个元素的值
void Swap(int& a, int& b) {
    int temp = a;
    a = b;
    b = temp;
}

// 调整并返回 pivot（基准）的正确位置
int Partition(std::vector<int>& arr, int low, int high) {
    int pivot = arr[high]; // 选择最后一个元素作为基准
    int i = (low - 1); // i 指向最左侧低于 pivot 值的元素

    for (int j = low; j < high; j++) {
        // 如果当前元素小于或等于 pivot
        if (arr[j] <= pivot) {
            i++; // i 向右移动
            Swap(arr[i], arr[j]); // 交换 arr[i] 和 arr[j]
        }
    }
    Swap(arr[i + 1], arr[high]); // 将基准移到正确的位置
    return (i + 1);
}

// 快速排序的主函数
void QuickSort(std::vector<int>& arr, int low, int high) {
    if (low < high) {
        int pi = Partition(arr, low, high); // 获取基准的位置

        QuickSort(arr, low, pi - 1);  // 对左侧部分进行递归排序
        QuickSort(arr, pi + 1, high); // 对右侧部分进行递归排序
    }
}

//////////////////////////////////////////////////////////////////////////////
// algo 1
void quick_sort(std::vector<int> &nums,int l,int r) {
  if (l + 1 >= r) return;
  int first = l, last = r - 1 ,key = nums[first];
  while (first < last) {
    while (first < last && nums[last] >= key) last--;//右指针 从右向左扫描 将⼩于piv的放 到左边
      nums[first] = nums[last];
    while (first < last && nums[first] <= key) first++;//左指针 从左向右扫描 将⼤于piv的 放到右边
      nums[last] = nums[first];
  }
  nums[first] = key;//更新piv
  quick_sort(nums, l, first);//递归排序 //以L为中间值，分左右两部分递归调⽤
  quick_sort(nums, first + 1, r);
}
//////////////////////////////////////////////////////////////////////////////

int main(int argc, char** argv) {
  std::vector<int> a = {11,0,34,66,2,5,95,4,46,27};
  if (argc >= 2) {
    std::cout<< "algo 1" << endl;
    quick_sort(a, 0, a.size());
  } else {
    std::cout<< "algo 2" << endl;
    QuickSort(a, 0, a.size());
  }
  for(int i=0; i<=a.size()-1; ++i) {
    std::cout<<a[i]<<" "; // print => 0 2 4 5 27 34 46 66 95
  }
  std::cout<<endl;
  return 0;
}
