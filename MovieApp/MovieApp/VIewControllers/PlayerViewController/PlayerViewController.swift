//
//  PlayerViewController.swift
//  MovieApp
//
//  Created by  on 30/06/2021.
//

import UIKit
import youtube_ios_player_helper
import AVKit

class PlayerViewController: UIViewController {
    @IBOutlet weak var playerView :YTPlayerView!    
    var youtubeIdentifier : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Now Playing"
        self.playerView.delegate = self
        self.playerView.load(withVideoId: youtubeIdentifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playerView.stopVideo()
    }
}

extension PlayerViewController : YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        print("error is \(error)")
        self.navigationController?.popViewController()
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch (state) {
        case YTPlayerState.ended:
                // handle ended state
            self.navigationController?.popViewController()
                break;
            default:
                break;
        }
    }
}
