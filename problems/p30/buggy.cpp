#include<bits/stdc++.h>
using namespace std;

int main() {
    string s, word;
    getline(cin, s);

    stringstream ss(s);
    bool first = true;

    while (ss >> word) {
        if (!first) cout << " ";
        cout << word;
    }

    return 0;
}
