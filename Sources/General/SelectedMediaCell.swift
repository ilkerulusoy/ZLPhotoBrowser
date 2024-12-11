//
//  File.swift
//  
//
//  Created by ilker on 18.07.2024.
//

import UIKit

class SelectedMediaCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var progressView: ZLProgressView = {
        let view = ZLProgressView()
        view.isHidden = true
        return view
    }()
    
    private lazy var bottomShadowView: UIImageView = {
        let shadowView = UIImageView(image: .zl.getImage("zl_shadow"))
        shadowView.contentMode = .scaleAspectFit
        shadowView.backgroundColor = .black
        shadowView.alpha = 0.6
//        shadowView.alpha = 0 // Initially hidden
        return shadowView
    }()
    
    private lazy var errorIconView: UIImageView = {
          let imageView = UIImageView(image: .zl.getImage("zl_download_error"))
          imageView.contentMode = .scaleAspectFit
          imageView.isHidden = true
          return imageView
      }()
    
    private var observation: NSKeyValueObservation?
    private var errorObservation: NSKeyValueObservation?
    
    private var model: ZLPhotoModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(bottomShadowView)
        contentView.addSubview(progressView)
        contentView.addSubview(errorIconView)

        imageView.frame = contentView.bounds
        
        bottomShadowView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomShadowView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bottomShadowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomShadowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomShadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomShadowView.heightAnchor.constraint(equalTo: contentView.heightAnchor) // Adjust this value to control shadow height
        ])
        bottomShadowView.isHidden = true
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 40),
            progressView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        errorIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorIconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            errorIconView.widthAnchor.constraint(equalToConstant: 30),
            errorIconView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage, photo: ZLPhotoModel) {
        imageView.image = image
        model = photo
        
        updateProgressUI(photo.progress)
        updateErrorView(photo.downloadError)

        observation = photo.observe(\.progress, options: [.new]) { [weak self] model, change in
            guard let newValue = change.newValue else { return }
            DispatchQueue.main.async { [weak self] in
                self?.updateProgressUI(newValue)
            }
        }
        
        errorObservation = photo.observe(\.downloadError, options: [.new]) { [weak self] model, change in
            guard let newValue = change.newValue else { return }
            DispatchQueue.main.async { [weak self] in
                self?.updateErrorView(newValue)
            }
        }
    }
    
    func updateErrorView(_ hasError: Bool) {
          errorIconView.isHidden = !hasError
          progressView.isHidden = hasError
          
          if hasError {
              self.bottomShadowView.isHidden = true
          }
      }
      
    
    func updateProgressUI(_ progress: CGFloat) {
        if progress < 0.99999 && model?.isDownloaded() == false {
            progressView.isHidden = false
            progressView.progress = progress
            
            // Fade in the shadow
            UIView.animate(withDuration: 0.3) {
                self.bottomShadowView.isHidden = false
            }
        } else {
            progressView.isHidden = true
            bottomShadowView.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        observation?.invalidate()
        observation = nil
        errorObservation?.invalidate()
        errorObservation = nil
        progressView.isHidden = true
        progressView.progress = 0
        bottomShadowView.isHidden = true
    }
}
