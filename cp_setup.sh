#!/bin/bash


cat << EOF | xclip -sel c
#include <bits/stdc++.h>

using namespace std;

#define sz(a) (int)(a.size())
#define uint unsigned int
#define ll long long
#define ull unsigned long long
#define dbg(v) \
	cout << "Line(" << __LINE__ << ") -> " << #v << " = " << (v) << endl;


inline int nxt() {
	int x;
	cin >> x;
	return x;
}

void solve() {
	// type here
}

int32_t main(void) {
	int T = nxt();
	while (T--) {
		solve();
	}

	return 0;
}
EOF
