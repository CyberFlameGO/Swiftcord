//
//  ChannelButton.swift
//  Swiftcord
//
//  Created by Vincent on 4/13/22.
//

import SwiftUI
import DiscordKitCommon
import DiscordKit
import CachedAsyncImage

struct ChannelButton: View {
    let channel: Channel
    @Binding var selectedCh: Channel?

    var body: some View {
		if channel.type == .dm || channel.type == .groupDM {
			DMButton(dm: channel, selectedCh: $selectedCh)
				.buttonStyle(DiscordChannelButton(isSelected: selectedCh?.id == channel.id))
		} else {
			GuildChButton(channel: channel, selectedCh: $selectedCh)
				.buttonStyle(DiscordChannelButton(isSelected: selectedCh?.id == channel.id))
		}
    }
}

struct GuildChButton: View {
	let channel: Channel
	@Binding var selectedCh: Channel?

	@EnvironmentObject var serverCtx: ServerContext

	private let chIcons = [
		ChannelType.voice: "speaker.wave.2.fill",
		.news: "megaphone.fill"
	]

	var body: some View {
		Button { selectedCh = channel } label: {
			let image = (serverCtx.guild?.rules_channel_id != nil && serverCtx.guild?.rules_channel_id! == channel.id) ? "newspaper.fill" : (chIcons[channel.type] ?? "number")
			Label(channel.label() ?? "nil", systemImage: image)
				.padding(.vertical, 6)
				.padding(.horizontal, 2)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}

struct DMButton: View {
	// swiftlint:disable identifier_name
	let dm: Channel
	@Binding var selectedCh: Channel?

	@EnvironmentObject var gateway: DiscordGateway

	var body: some View {
		Button { selectedCh = dm } label: {
			HStack {
				if dm.type == .dm, let user = gateway.cache.users[dm.recipient_ids![0]] {
					BetterImageView(url: user.avatarURL(size: 64))
						.frame(width: 32, height: 32)
						.clipShape(Circle())
				} else {
					Image(systemName: "person.2.fill")
						.foregroundColor(.white)
						.frame(width: 32, height: 32)
						.background(.red)
						.clipShape(Circle())
				}

				VStack(alignment: .leading, spacing: 2) {
					Text(dm.label(gateway.cache.users) ?? "nil")
					if dm.type == .groupDM {
						Text("\((dm.recipient_ids?.count ?? 2) + 1) dm.group.memberCount")
							.font(.caption)
					}
				}
				Spacer()
			}
			.padding(.horizontal, 6)
			.padding(.vertical, 5)
		}
	}
}
