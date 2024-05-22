#include <vector>
#include <iostream>

   int largestRectangleArea(std::vector<int>& heights) {
        int ans = 0;
        std::vector<int> st;
    heights.insert(heights.begin(), 0);
    heights.push_back(0);
    for (int i = 0; i < heights.size(); i++)
    {
        while (!st.empty() && heights[st.back()] > heights[i])
        {
            int cur = st.back();
            st.pop_back();
            int left = st.back() + 1;
            int right = i - 1;
            ans = std::max(ans, (right - left + 1) * heights[cur]);
        }
        st.push_back(i);
    }
    return ans;


    }

int main() {
  std::vector<int> a={3,3,4,3};
  std::cout << largestRectangleArea(a) << std::endl;
}
