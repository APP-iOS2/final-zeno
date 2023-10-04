//
//  AuthService.swift
//  Zeno
//
//  Created by Muker on 2023/09/30.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class UserViewModel: ObservableObject {
	/// 파이어베이스 Auth의 User
	@Published var userSession: FirebaseAuth.User?
	/// 현재 로그인된 유저
	@Published var currentUser: User?
	
	init() {
		Task {
			try await loadUserData()
		}
	}
	/// 이메일 로그인
	@MainActor
    func login(email: String, password: String) async throws {
		do {
			let result = try await Auth.auth().signIn(withEmail: email, password: password)
			self.userSession = result.user
			try await loadUserData()
			print("🔵 로그인 성공")
		} catch {
			print("🔴 로그인 실패. 에러메세지: \(error.localizedDescription)")
		}
	}
	/// 이메일 회원가입
	@MainActor
	func createUser(email: String, passwrod: String, name: String, gender: String, description: String) async throws {
		do {
			let result = try await Auth.auth().createUser(withEmail: email, password: passwrod)
			self.userSession = result.user
			let user = User(id: result.user.uid,
							name: name,
							gender: gender,
							description: description,
							kakaoToken: "카카오토큰",
							coin: 0,
							megaphone: 0,
							showInitial: 0,
							buddyList: [:])
			await uploadUserData(user: user)
			print("🔵 회원가입 성공")
		} catch {
			print("🔴 회원가입 실패. 에러메세지: \(error.localizedDescription)")
		}
	}
	/// 이메일 회원가입 정보 등록하기
    func uploadUserData(user: User) async {
        self.currentUser = user
        try? await FirebaseManager.shared.create(data: user)
    }
	/// 유저 데이터 가져오기
    @MainActor
    func loadUserData() async throws {
		self.userSession = Auth.auth().currentUser
		guard let currentUid = userSession?.uid else { return print("로그인된 유저 없음")}
		print("\(currentUid)")
		self.currentUser = try await UserViewModel.fetchUser(withUid: currentUid)
		print("현재 로그인된 유저: \(currentUser ?? User.dummy[0])")
	}
	/// 로그아웃
	func logout() {
		try? Auth.auth().signOut()
		self.userSession = nil
		self.currentUser = nil
	}
    
    /// 코인 사용 업데이트 함수
    func updateUserCoin(to: Int) async {
        guard let currentUser else { return }
        var coin = currentUser.coin
        coin += to
        try? await FirebaseManager.shared.update(data: currentUser, value: \.coin, to: coin)
        try? await loadUserData()
    }
    /// 초성확인권 사용 업데이트 함수
    func updateUserInitialCheck(to: Int) async {
        guard let currentUser else { return }
        var initialCheck = currentUser.showInitial
        initialCheck += to
        try? await FirebaseManager.shared.update(data: currentUser, value: \.showInitial, to: initialCheck)
        try? await loadUserData()
    }
    // 인앱결제 이루어졌을때 count가 어떻게 될지 모르겠어서 일단 남겨놓은.
    func purchaseUserInitialCheck(user: User) async {
        var initialCheck = user.showInitial
        initialCheck += 10
        try? await FirebaseManager.shared.update(data: user, value: \.showInitial, to: initialCheck)
        
        Task {
            try await loadUserData()
        }
    }
}

/// static 메서드 모아놓은 extension
extension UserViewModel {
	/// 유저 패치하기
	static func fetchUser(withUid uid: String) async throws -> User {
        let result = await FirebaseManager.shared.read(type: User.self, id: uid)
        switch result {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
	}
}
