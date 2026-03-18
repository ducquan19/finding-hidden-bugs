#include<bits/stdc++.h>
using namespace std;

int main() {
    int x1, y1, x2, y2;
    int x, y;

    cin >> x1 >> y1 >> x2 >> y2;
    cin >> x >> y;

    int xmin = min(x1, x2);
    int xmax = max(x1, x2);
    int ymin = min(y1, y2);
    int ymax = max(y1, y2);

    if (x >= xmin && x <= xmax && y >= ymin && y <= ymax) {
        cout << "Yes\n";
    } else {
        cout << "No\n";
    }

    return 0;
}
