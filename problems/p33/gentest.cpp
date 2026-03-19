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
		long long a, b, c;

		if (t == 1) {
			a = 10; b = 10; c = 5; // đã bằng nhau
		}
		else if (t == 2) {
			a = 0; b = 1000000000; c = 1; // nhiều bước
		}
		else if (t == 3) {
			a = 1000000000; b = 0; c = 1000000000; // 1 bước
		}
		else {
			a = rdll(0, 1000000000);
			b = rdll(0, 1000000000);
			c = rdll(1, 1000000000);
		}

		fout << a << " " << b << " " << c << '\n';
	}

	return 0;
}
