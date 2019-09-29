//
//  BsuirApi+Combine.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 8/6/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import Foundation
import Combine
import BsuirApi

extension RequestsManager {

    public func dataRequest<T: Target>(for target: T) -> AnyPublisher<(Data, URLResponse), DataRequestError> {
        AnyPublisher(Future { handler in self.dataRequest(for: target, completion: handler) }.share())
    }

    func request<T: Target>(_ target: T) -> AnyPublisher<T.Value, RequestError> {
        AnyPublisher(Future { handler in self.request(target, completion: handler) }.share())
    }
}
