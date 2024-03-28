#include <vector>
#include <algorithm>
#include <iostream>

using namespace std;

class Solution {
public:
    void merge1(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        int p1 = 0;
        int p2 = 0;
        while (p2 < n) {
            if (nums1[p1] < nums2[p2]) {
                p1++;
                continue;
            } else {
                nums1.insert(nums2.begin()+p1, nums2[p2]);
                p2++;
                continue;
            }
        }

    }
  void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
         vector<int> result(m + n);
        std::merge(nums1.begin(), nums1.begin() + m, nums2.begin(), nums2.begin() + n, result.begin());
        nums1 = result;
    }
};

int main() {
    Solution s;
    vector<int> v1 = {1, 0, 1};
    vector<int> v2 = {2};
    s.merge(v1, 1, v2, 1);
    cout << "result:" << endl;
    for (auto i: v1) {
        cout << i << " ";
    }
    cout << endl;
    cout << "use itelator" << endl;
    for (auto i=v1.begin(); i != v1.end(); i++) {
        cout << *i << " ";
    }

    cout << endl;
    cout << "use iterator explicitly" << endl;
    for (vector<int>::iterator i=v1.begin(); i != v1.end(); i++) {
        cout << *i << " ";
    }

    cout << endl;
    cout << "use vector index explicitly" << endl;
    for (int i=0; i < v1.size(); i++) {
        cout << v1[i] << " ";
    }


    cout << endl;
    //cout << v1.data();
}