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
		int len = rd(1, 100);

		// sinh chuỗi gồm chữ + nhiều space lộn xộn
		string s = "";

		for (int i = 0; i < len; i++) {
			int type = rd(1, 3);

			if (type == 1) {
				// ký tự chữ thường
				s += char('a' + rd(0, 25));
			} else {
				// space (tạo nhiều space liên tiếp)
				int spaces = rd(1, 3);
				while (spaces--) s += ' ';
			}
		}

		// thêm khả năng có space đầu/cuối
		if (rd(0, 1)) s = string(rd(1, 5), ' ') + s;
		if (rd(0, 1)) s += string(rd(1, 5), ' ');

		// ghi ra file
		fout << s << "\n";
	}

	return 0;
}
