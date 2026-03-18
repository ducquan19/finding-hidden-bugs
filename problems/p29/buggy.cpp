#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    getline(cin, s);

    int cnt = 0;

    for (int i = 0; i < s.size(); i++) {
        if (isdigit(s[i])) {
            if (!isdigit(s[i - 1])) {
                cnt++;
            }
        }
    }

    cout << cnt;
    return 0;
}
