#include <bits/stdc++.h>
using namespace std;

#include <filesystem>

static string two(int x) {
	string s = to_string(x);
	if ((int)s.size() < 2) s = string(2 - (int)s.size(), '0') + s;
	return s;
}

int main(int argc, char** argv) {
	ios::sync_with_stdio(false);
	cin.tie(nullptr);

	if (argc < 4) {
		cerr << "Usage: gentest <tests_dir> <seed> <num_tests>\n";
		return 2;
	}

	const string testsDir = argv[1];
	const unsigned seed = (unsigned)stoull(argv[2]);
	const int numTests = max(1, stoi(argv[3]));

	mt19937 rnd(seed);
	auto rd = [&](int l, int r) {
		return uniform_int_distribution<int>(l, r)(rnd);
	};

    auto rdll = [&](long long l, long long r) {
    	return uniform_int_distribution<long long>(l, r)(rnd);
	};

	std::filesystem::create_directories(std::filesystem::path(testsDir));

	for (int t = 1; t <= numTests; ++t) {
		const string path = testsDir + "/" + two(t) + ".in";
		ofstream fout(path, ios::binary);
		if (!fout) {
			cerr << "Cannot write: " << path << "\n";
			return 3;
		}

		// Your code here
		int _t = rd(1, 10000);
		fout << _t << '\n';
		while (_t--) {
            int n = rd(1, 50);
            fout << n << '\n';

            vector<int> a(n);
            for (int i = 0; i < n; ++i) {
                a[i] = rd(0, 49);
                fout << a[i] << " ";
            }
            fout << '\n';

            string s(n, 'a');

            // 50% tạo test YES, 50% tạo test NO
            bool makeYES = rd(0, 1);

            if (makeYES) {
                // Tạo ánh xạ hợp lệ
                map<int, char> mp;
                for (int i = 0; i < n; ++i) {
                    if (!mp.count(a[i])) {
                        mp[a[i]] = 'a' + rd(0, 25);
                    }
                    s[i] = mp[a[i]];
                }
            } else {
                // Tạo ánh xạ sai (cố tình conflict)
                map<int, char> mp;
                for (int i = 0; i < n; ++i) {
                    if (!mp.count(a[i])) {
                        mp[a[i]] = 'a' + rd(0, 25);
                    }
                    s[i] = mp[a[i]];
                }

                // phá 1 vị trí để tạo mâu thuẫn
                int pos = rd(0, n - 1);
                char newChar;
                do {
                    newChar = 'a' + rd(0, 25);
                } while (newChar == s[pos]);

                s[pos] = newChar;
            }

            fout << s << '\n';
		}
	}

	return 0;
}
