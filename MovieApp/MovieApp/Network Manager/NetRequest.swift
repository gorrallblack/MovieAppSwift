//
//  NetRequest.swift
//  OCB5
//
//  Created by  on 2018. 9. 29..
//  Copyright © 2016년 skplanet. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

struct NetRequest {
    // DashboardChannels
    //
    // @url /todos/1
    // @method GET
    // @param (required) tmp1 testParameter
    // @param (required) tmp2 testParameter
    static func fetchMainMovieList(_ param: [String: String]? = nil) -> Promise<MovieData> {
        let task = NetworkTask<MovieData>(method: .get, parameter: param, header: NetworkUtil.getHttpheader(nil))
        return task.requestNetworkConnection(AppNetworkURL.SERVER_URL() + PopularMovies.POPULAR + "?api_key=\(CommonConstants.API_KEY)" )
    }
    
    static func fetchMovieDetail(_ param: [String: String]? = nil, _ movieID: String) -> Promise<MovieDetailData> {
        let task = NetworkTask<MovieDetailData>(method: .get, parameter: param, header: NetworkUtil.getHttpheader(nil))
        return task.requestNetworkConnection(AppNetworkURL.SERVER_URL() + "\(String(describing: movieID))" + "?api_key=\(CommonConstants.API_KEY)" )
    }
    
    static func fetchMovieTrailerDetail(_ param: [String: String]? = nil, _ movieID: String) -> Promise<MovieTrailer> {
        let task = NetworkTask<MovieTrailer>(method: .get, parameter: param, header: NetworkUtil.getHttpheader(nil))
        return task.requestNetworkConnection(AppNetworkURL.SERVER_URL() + "\(String(describing: movieID))/videos" + "?api_key=\(CommonConstants.API_KEY)" )
    }
}
