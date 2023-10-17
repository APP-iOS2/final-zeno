//
//  CommReqestView.swift
//  Zeno
//
//  Created by Muker on 2023/10/08.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommRequestView: View {
	@EnvironmentObject private var userViewModel: UserViewModel
	@EnvironmentObject private var commViewModel: CommViewModel
	
	@Binding var isShowingCommRequestView: Bool
	@State var aplicationStatus: Bool
	@State private var showingAlert = false
	
	private let throttle: Throttle = .init(delay: 1)
	
	var comm: Community
	
	var body: some View {
		NavigationStack {
			VStack {
				Spacer()
				Spacer()
				// 이미지
				ZenoKFImageView(comm)
					.frame(maxWidth: .screenWidth * 0.8, maxHeight: .screenWidth * 0.8)
					.clipShape(Circle())
					.overlay {
						Circle().stroke(.gray, lineWidth: 2)
					}
					.shadow(radius: 7)
					.padding(20)
				// 커뮤니티 설명
				Spacer()
				VStack(alignment: .leading, spacing: 7) {
					Text(comm.name)
						.font(.extraBold(24))
						.lineLimit(2)
						.padding(.vertical, 20)
					Section {
						Text(comm.description)
							.lineLimit(nil)
							.font(.regular(18))
						Text("\(comm.joinMembers.count) / \(comm.personnel) | 개설일 \(comm.createdAt.convertDate)")
							.font(.thin(14))
							.foregroundColor(.gray)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(20)
				
				Button {
					throttle.run {
						Task {
							do {
								try await commViewModel.requestJoinComm(comm: comm)
								try await userViewModel.addRequestComm(comm: comm)
								self.showingAlert = true
								self.aplicationStatus = true
								print("성공\(self.showingAlert)")
							} catch {
								print("실패")
							}
						}
					}
				} label: {
					ZStack {
						Rectangle()
							.frame(width: .screenWidth * 0.9, height: .screenHeight * 0.07)
							.cornerRadius(15)
							.foregroundColor(aplicationStatus ? .gray : .mainColor)
							.opacity(0.8)
							.shadow(radius: 3)
						Image(systemName: "paperplane")
							.font(.system(size: 21))
							.offset(x: -.screenWidth * 0.3)
							.foregroundColor(aplicationStatus ? .gray : .white)
						Text(aplicationStatus ? "이미 가입신청한 그룹" : "가입 신청 하기")
							.font(ZenoFontFamily.NanumSquareNeoOTF.extraBold.swiftUIFont(size: 20))
							.foregroundColor(aplicationStatus ? .gray : .white)
					}
					.offset(y: -20)
					.padding(.top, 30)
				}
				.disabled(aplicationStatus)
			}
			.zenoWarning("그룹에 가입신청을 보냈습니다", isPresented: $showingAlert)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						isShowingCommRequestView = false
					} label: {
						Image(systemName: "xmark")
							.foregroundColor(.primary)
					}
				}
			}
		}
	}
}

struct CommReqestView_Previews: PreviewProvider {
	static var previews: some View {
		CommRequestView(isShowingCommRequestView: .constant(true), aplicationStatus: true, comm: Community.dummy[0])
			.environmentObject(UserViewModel())
			.environmentObject(CommViewModel())
	}
}
