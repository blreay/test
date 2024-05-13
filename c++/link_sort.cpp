//*****************************************************
/// This algorithm cannot work, it lead to hang
//*****************************************************
//
#include <iostream>
#include <tuple>

struct ListNode {
    int val;
    ListNode *next;
    ListNode(int x) : val(x), next(nullptr) {}
};
// 用于打印链表的辅助函数
void printList(ListNode *head) {
    while (head) {
        std::cout << head->val << " ";
        head = head->next;
    }
    std::cout << "\n";
}


// 该函数的目的是为了划分链表，并返回分区后子链表的头和尾指针
std::pair<ListNode*, ListNode*> partition(ListNode *head, ListNode *end) {
    ListNode *pivot = end; // 选择最后一个元素作为基准
    ListNode *prev = nullptr, *cur = head, *tail = pivot, *tmp2 = nullptr;

    // 这个循环将链表中小于基准的节点移到前面，大于等于基准的节点留在原位
    while (cur != pivot) {
        if (cur->val < pivot->val && prev != nullptr) {
            if (prev) {
                prev->next = cur->next;
            }
            tmp2 = cur->next;
            cur->next = head;
            head = cur;
            //cur = prev ? prev->next : head;
            // cur = prev ? prev->next : tmp2;
            cur = tmp2;
        } else {
            prev = cur;
            cur = cur->next;
        }
    }

    return { head, tail };
}

// 快速排序递归函数
ListNode* quicksort(ListNode *head, ListNode *end) {
    if (!head || head == end) return head;

    ListNode *newHead = nullptr, *newEnd = nullptr;

    // 划分链表，newHead 是划分后的新链表头，newEnd 是划分后的新链表尾
    std::tie(newHead, newEnd) = partition(head, end);

    // 递归地对小于基准值的子链表进行快速排序
    if (newHead != end) {
        ListNode *tmp = newHead;
        while (tmp->next != end) {
            tmp = tmp->next; // 找到子链表的尾部
        }
        tmp->next = nullptr; // 断开子链表和后面的链表
        newHead = quicksort(newHead, tmp);
        std::cout << "end1: " << tmp->val << "---";
        printList(newHead);
        
        // 为了合并子链表，需要找到最终子链表的尾部
        tmp = newHead;
        while (tmp->next) {
            tmp = tmp->next;
        }
        tmp->next = end;
        std::cout << "end11:";
        printList(newHead);
    }

    // 递归地对大于等于基准值的子链表进行快速排序
    end->next = quicksort(end->next, newEnd);
        std::cout << "end2:";
        printList(end->next);

    return newHead;
}

// 排序链表接口
ListNode* sortList(ListNode* head) {
    // 找到链表的尾部节点
    ListNode *end = head;
    while (end && end->next) {
        end = end->next;
    }
    return quicksort(head, end);
}

int main() {
    ListNode *head = new ListNode(4);
    head->next = new ListNode(2);
    head->next->next = new ListNode(1);
    head->next->next->next = new ListNode(3);

    std::cout << "Original List: ";
    printList(head);

    head = sortList(head);

    std::cout << "Sorted List: ";
    printList(head);

    return 0;
}
