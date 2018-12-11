//
//  BOMovieData.swift
//  BoxOffice
//
//  Created by 최영준 on 2018. 7. 16..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

struct APIResponseForMovies: Codable {
    let movies: [MoviesData]
}

struct APIResponseForComments: Codable {
    let comments: [CommentData]
}

struct MoviesData: Codable {
    var grade: Int
    var thumb: String
    var reservationGrade: Int
    var title: String
    var reservationRate: Double
    var userRating: Double
    var date: String
    var id: String
    private enum CodingKeys: String, CodingKey {
        case reservationGrade = "reservation_grade"
        case reservationRate = "reservation_rate"
        case userRating = "user_rating"
        case grade, thumb, title, date, id
    }
}

struct MovieData: Codable {
    var audience: Int
    var actor: String
    var duration: Int
    var director: String
    var synopsis: String
    var genre: String
    var grade: Int
    var image: String
    var reservationGrade: Int
    var title: String
    var reservationRate: Double
    var userRating: Double
    var date: String
    var id: String
    private enum CodingKeys: String, CodingKey {
        case reservationGrade = "reservation_grade"
        case reservationRate = "reservation_rate"
        case userRating = "user_rating"
        case audience, actor, duration, director, synopsis, genre, grade, image, title, date, id
    }
}

struct CommentData: Codable {
    var rating: Double
    var timestamp: Double?
    var writer: String
    var id: String
    var contents: String
    var writerImage: String?
    private enum CodingKeys: String, CodingKey {
        case id = "movie_id"
        case writerImage = "writer_image"
        case rating, timestamp, writer, contents
    }
}

struct WriteCommentData: Codable {
    var rating: Double
    var writer: String
    var movieId: String
    var contents: String
    var timestamp: Double
    private enum CodingKeys: String, CodingKey {
        case movieId = "movie_id"
        case rating, writer, contents, timestamp
    }
}
