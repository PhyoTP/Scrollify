//
//  File.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 14/11/25.
//

import Foundation
import FoundationModels
import Playgrounds
@Generable
struct Video: Identifiable, Equatable{
    var id = UUID()
    @Guide(description: "What the creator of the video would put in the caption, one sentence")
    var caption: String
    @Guide(description: "Like the hashtags of a video")
    var tags: [String]
    @Guide(description: "A very short description of the video")
    var text: String
    @Guide(description: "A iOS system image that is related to the video")
    var image: String
    @Guide(description: "The username of the creator of the video")
    var creator: String
}

func generateVideo(tags: Set<String>, creators: Set<String>) async throws -> Video {
    let instructions = """
    You are a recommendation-aware video generation system. Your task is to create a personalized video concept for a user by analyzing their preferences and intelligently selecting compatible tags.

    You will be provided with three types of information about the user:

    1. Reference examples showing how tags combine to create video concepts:
    \(premadeVideos)

    2. Tags the user has liked in the past:
    \(tags)

    3. Creators the user follows:
    \(creators)

    Your goal is to create a compelling video concept by selecting and combining tags from the user's liked tags. If your final concept matches the style of content that one of the followed creators typically produces, you should assign that creator to the video.


    Before providing your final video concept, complete each of the following steps:

    1. **List and categorize all liked tags**: Write out each individual liked tag from the user's history, numbering them as you go (e.g., 1. tag_name, 2. another_tag, etc.). For each tag, assign it to a genre, theme, or style category (e.g., "horror", "comedy", "educational", "animated", etc.). This helps you keep all preferences visible. It's OK for this section to be quite long.

    2. **Identify patterns and themes**: Review your categorized tags and identify recurring patterns, themes, or categories. What types of content does this user consistently enjoy? Note any strong preferences.

    3. **Brainstorm tag combinations**: Generate 2-3 potential tag combinations that could work well together. For each combination, write it out in a structured format like "Combination 1: [tag_a, tag_b, tag_c, tag_d]" with the specific tags you're considering using.

    4. **Check compatibility**: For each potential combination, explicitly verify that all tags belong to related or compatible genres and themes. Reference specific video examples from the examples provided above that demonstrate similar tag combinations working well together. Quote relevant parts of those examples. List any potential conflicts you identify. Do NOT proceed with combinations that mix unrelated or conflicting genres (for example: do not combine "horror" with "romantic comedy", or "educational documentary" with "slapstick humor"). Only compatible tags should be combined.

    5. **Evaluate tag count**: For your most promising combination(s), assess whether you have an appropriate number of tags. Too few tags (1-2) may result in a generic video concept, while too many tags (8+) may create an unfocused or contradictory concept. Aim for a balanced selection that is specific yet coherent (typically 3-6 tags).

    6. **Select final tags and draft concept**: Choose your final tag combination and describe what kind of video would result from this selection. Explain why it aligns with the user's preferences.

    7. **Match against followed creators**: For each creator in the user's followed list, write out what type of content they typically produce. Then compare your final video concept against each creator's style. If your concept closely matches a creator's style, note that creator. If no creator is a strong match, note that as well.

    ## Output Format

    After completing your analysis, provide your final video concept in the following format:



"""
    let prompt = "Tags: \(tags.joined(separator: ",")) \nCreators: \(creators.joined(separator: ","))"
    let session = LanguageModelSession(instructions: instructions)
    return try await session.respond(to: prompt, generating: Video.self).content
}
struct Comment{
    var commentor: String
    var comment: String
}
let premadeVideos = [
    Video(caption: "Cats to brighten your day :)", tags: ["cat", "pets", "cute", "animals"], text: "A video of cats", image: "cat",creator: "cutecats191"),
    Video(caption: "This robber did what??", tags: ["news", "happenings", "daily"], text: "A news video about a robber", image: "newspaper", creator: "daily.news"),
    Video(caption: "Did you know that bees were used to make honey 5000 years ago?", tags: ["daily", "facts", "learning"], text: "A video about bee facts", image: "tree", creator: "factsdaily"),
    Video(caption: "A day in the life of a cat", tags: ["daily", "animals", "cute", "cat"], text: "A video of a day in the life of a cat", image: "cat", creator: "cutecats191"),
    Video(caption: "The history of the internet", tags: [ "learning", "facts"], text: "A video about the history of the internet", image: "globe", creator: "technews"),
    Video(caption: "Follow me to find this hidden gem in downtown LA!", tags: ["food", "hidden"], text: "A video about an underrated restaurant", image: "fork.knife", creator: "alexparkman"),
    Video(caption: "GRWM to go to the beach!", tags: ["grwm", "beauty", "outdoors", "fashion"], text: "A makeup video", image: "theatermask.and.paintbrush", creator: "makeupwithemily"),
    Video(caption: "The boy found himself in a well", tags: ["drama", "tvshow", "movies","entertainment"], text: "A movie clip", image: "movieclapper", creator: "movieclips318"),
    Video(caption: "The best red curry recipe...", tags: ["cooking","food","recipes"], text: "A cooking video", image: "frying.pan", creator: "mr.chef176"),
    Video(caption: "Doctors don't want you to know this one hack...", tags: ["podcast","health"], text: "A questionable podcast on health tips", image: "microphone", creator: "thehealingpodcast"),
    Video(caption: "new niche number 94, keep ts niche", tags: ["brainrot","memes","funny"], text: "A funny meme video", image: "face.smiling", creator: "boomtownmemes"),
    Video(caption: "So that's why we drive on the left", tags: ["skits","funny","entertainment"], text: "A satirical skit", image: "theatermask.and.paintbrush", creator: "palthecreator"),
    Video(caption: "5 workouts every bodybuilder needs to know", tags: ["workout","fitness","health"], text: "A workout video", image: "figure.strengthtraining.traditional", creator: "theworkoutboss"),
    Video(caption: "Velocity breaks his mic trying to beat this game", tags: ["gaming","stream","funny"], text: "A stream clip", image: "headset", creator: "streamclips531"),
    Video(caption: "He put WHAT in his red curry??", tags: ["reaction","cooking","food"], text: "A reaction video to a cooking video", image: "person.wave.2", creator: "unclerobert"),
    Video(caption: "The INSANE goal that put Ressi on the map", tags: ["football","soccer","sports","edits"], text: "A football clip edit", image: "soccerball", creator: "footballedits21"),
    Video(caption: "The car that beat the Viron by 1.2 seconds...", tags: ["edits","cars"], text: "An edit of the fastest car in the world", image: "car.2", creator: "madeforspeed"),
    Video(caption: "Comment down below what I should do next!", tags: ["dance"], text: "A dance video", image: "figure.dance", creator: "mr.slick63")
]
#Playground {
    var creators = [String:Int]()
    for v in premadeVideos{
        if let creatorCount = creators[v.creator]{
            creators[v.creator] = creatorCount + 1
        }else{
            creators[v.creator] = 1
        }
    }
    print(creators)
}
//func generateVideo(likedTags: Set<String>, creators: Set<String>, allVideos: [Video]) async throws -> Video {
//    var prompt = "You are a short-form content creator. Create a short video."
//    var chosenCreator = ""
//    var chosenTags = [String]()
//    if creators.count > 5{
//        let rand = Bool.random()
//        if rand{
//            chosenCreator = creators.randomElement()!
//            let creatorVideos = allVideos.filter{$0.creator == chosenCreator}
//            prompt = "You are a short-form content creator by the name of \(chosenCreator). You are going to make a short video. Here are some videos you have made: \(creatorVideos) Make a video similar to the videos you have been making."
//        }
//    }
//    let allCreators = allVideos.map { $0.creator }
//    if likedTags.count > 5{
//        chosenTags = [likedTags.randomElement()!]
//        let rand = Bool.random()
//        if rand{
//            chosenTags.append(likedTags.randomElement()!)
//        }
//        let exampleVideos = allVideos.filter{$0.tags.contains(where: { chosenTags.contains($0) })}
//        prompt = "You are a short-form content creator. You are going to make a short video on the topic(s) of: \(chosenTags.joined(separator: ", ")). Here are some examples of videos on these topics: \(allVideos.filter{$0.tags.contains(where: { chosenTags.contains($0) })})"
//        
//    }else{
//        chosenTags = [tags.randomElement()!]
//        let rand = Bool.random()
//        if rand{
//            chosenTags.append(tags.randomElement()!)
//        }
//        prompt = "You are a short-form content creator. You are going to make a short video on the topic(s) of: \(chosenTags.joined(separator: ", "))."
//    }
//    let session = LanguageModelSession()
//    var generatedVideo = try await session.respond(to: prompt, generating: Video.self).content
//    if !chosenCreator.isEmpty{
//        generatedVideo.creator = chosenCreator
//    }else{
//        generatedVideo.tags = chosenTags
//        
//    }
//    return generatedVideo
//}
