#include <iostream>

struct ListNode {
    int val;
    ListNode *next;
    ListNode(int x) : val(x), next(nullptr) {}
};

// 快速排序的辅助函数，返回分区节点
ListNode* partition(ListNode *low, ListNode *high, ListNode **newLow, ListNode **newHigh) {
    // 选取最后一个元素为基准
    int pivot = high->val;
    ListNode *prev = nullptr, *cur = low, *tail = high, *pivotNode = high;

    // newLow 和 newHigh 帮助调整首尾指针
    *newLow = nullptr;
    *newHigh = nullptr;

    // 遍历链表，并根据基准对节点进行分类
    while (cur != high) {
        if (cur->val < pivot) {
            if (*newLow == nullptr) *newLow = cur;
            prev = cur;
            cur = cur->next;
        } else {
            if (prev) prev->next = cur->next;
            ListNode *temp = cur->next;
            cur->next = nullptr;
            tail->next = cur;
            tail = cur;
            cur = temp;
        }
    }

    if (*newLow == nullptr) {
        *newLow = pivotNode;
    }

    *newHigh = tail;

    return pivotNode;
}

ListNode* getTail(ListNode *cur) {
    while (cur != nullptr && cur->next != nullptr)
        cur = cur->next;
    return cur;
}

// 快速排序的递归函数
ListNode* quickSortRec(ListNode *low, ListNode *high) {
    if (!low || low == high) return low;

    ListNode *newLow = nullptr, *newHigh = nullptr;

    // 对链表进行分区
    ListNode *pivotNode = partition(low, high, &newLow, &newHigh);

    if (newLow != pivotNode) {
        // 递归排序小于基准值的链表部分
        ListNode *temp = newLow;
        while (temp->next != pivotNode)
            temp = temp->next;
        temp->next = nullptr;

        newLow = quickSortRec(newLow, temp);

        // 将排序后的链表与基准节点连接起来
        getTail(newLow)->next = pivotNode;
    }

    // 递归排序大于基准值的链表部分
    pivotNode->next = quickSortRec(pivotNode->next, newHigh);

    return newLow;
}

void quickSort(ListNode **headRef) {
    *headRef = quickSortRec(*headRef, getTail(*headRef));
}

// 打印链表
void printList(ListNode *head) {
    while (head) {
        std::cout << head->val;
        head = head->next;
        if (head) std::cout << " -> ";
    }
    std::cout << std::endl;
}

int main() {
    ListNode *head = new ListNode(3);
    head->next = new ListNode(5);
    head->next->next = new ListNode(8);
    head->next->next->next = new ListNode(2);
    head->next->next->next->next = new ListNode(1);

    std::cout << "Original list: ";
    printList(head);

    quickSort(&head);

    std::cout << "Sorted list: ";
    printList(head);

    return 0;
}
