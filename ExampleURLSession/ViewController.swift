//
//  ViewController.swift
//  ExampleURLSession
//
//  Created by Anatoly Ryavkin on 20.10.2020.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var arrayImageView: [UIImageView]!


    let arrayURL = [ "https://ancsgroup.ru/resources/000/000/000/001/583/1583325_1024x768.png",
                     "https://i.pinimg.com/736x/79/83/76/7983766b4e9a19eaaaf3fc792cf20e1f.jpg",
                     "https://moscow.sm-news.ru/wp-content/uploads/2019/10/14/sberbank.jpg",
                     "https://akket.com/wp-content/uploads/2019/09/Mobilnyi-bank-Sberbank.jpg"];

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func async(_ sender: Any) {
        for (index,imageView) in arrayImageView.enumerated() {
            LoaderImages.Shared.getImageFromURL(imageURL: arrayURL[index], endRunQueue: DispatchQueue.main) { image in
                imageView.image = image
            }
        }
    }
    

    @IBAction func sync(_ sender: Any) {

        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 0;
        queue.qualityOfService = .default;

        var arrayIm = Array<UIImage>()

        for (index,_) in arrayImageView.enumerated() {
            LoaderImages.Shared.getImageFromURL(imageURL: arrayURL[index], endRunQueue: nil) { image in
                arrayIm.append(image)
                if index == 3 {
                    queue.maxConcurrentOperationCount = 1
                }
            }
        }

        queue.addOperation {
            DispatchQueue.main.async {
                for (index,imageView) in self.arrayImageView.enumerated() {
                    imageView.image = arrayIm[index]
                }
            }
        }
    }
    
    @IBAction func del(_ sender: Any) {

        for imageView in arrayImageView {
            imageView.image = UIImage.init(named: "placeholder")
        }
    }

}

