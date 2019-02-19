import UIKit
import Foundation

class PhotoFolderCell: UICollectionViewCell, PhotoSnippetCellProtocol, PhotoItemsDraggable, DropViewProvidable
{
  lazy var dropView: UIView = self.setDropView()
 
  lazy var dropDelegate: UIDropInteractionDelegate =
   {
    let dropDelegate = FolderCellDropViewDelegate(owner: self)
    return dropDelegate
  }()
 
  var groupTaskCount: Int = 0

  var hostedView: UIView { return photoCollectionView }
  var hostedAccessoryView: UIView?
 
  weak var photoSnippet: PhotoSnippet!
 
  weak var photoSnippetVC: PhotoSnippetViewController!
 
  @IBOutlet weak var photoCollectionView: UICollectionView! //hosted folder cells internal CV...
 
  weak var hostedItem: PhotoItemProtocol?
  //The PhotoFolderItem that is currently hosted and visualized by this type of UICollectionViewCell...
  {
   didSet
   {
    guard let hosted = self.hostedItem as? PhotoFolderItem else { return }
    
    dropView.isHidden = isDraggable
    
    // if zoomView is open and dispays this folder cell we will use [PhotoItems] of ZoomView to preserve ordering
    if let zv = photoSnippetVC.photoCollectionView.zoomView, zv.zoomedPhotoItem === hosted
    {
     self.photoItems = zv.photoItems
    }
    else //otherwise construct new PhotoItems and assign them to the dequed FolderCell [PhotoItems]...
    {
     self.photoItems = hosted.singlePhotoItems
    }
    
    self.photoCollectionView.reloadData() //reload nested CV when [PhotoItems] is assigned to FolderCell DS.
    
    hosted.hostingCollectionViewCell = self
    //weak reference to this folder cell that will display this PhotoFolderItem...
    
    self.photoCollectionView.alpha = hosted.isSelected ? 0.5 : 1
    
    self.isDragAnimating = hosted.isDragAnimating //|| hosted.isDropAnimating
    //if cell drag waggle animation deleted and hosted item is in selected state recover animation...
    
    self.photoFolder = hosted //???
    self.groupTaskCount = 0   //???
    
   }
  }//weak var hostedItem: PhotoItemProtocol?...
 

  private final var hostedCells: [PhotoFolderCollectionViewCell]
  {
   return self.photoItems.compactMap{self.photoItemIndexPath(photoItem: $0)}
                         .compactMap{self.photoCollectionView.cellForItem(at: $0) as? PhotoFolderCollectionViewCell}
  }

  func dragWaggleBegin()
  //this individual method realization overrides one defined by PhotoCollectionViewProtocol to add up some func!!
  {
   self.startWaggleAnimation()
   hostedCells.forEach{ $0.dragWaggleBegin() } //add-on...
   
  }

  func dragWaggleEnd()
  //this individual method realization overrides one defined by PhotoCollectionViewProtocol to add up some func!!
  {
   self.stopWaggleAnimation()
   hostedCells.forEach{ $0.dragWaggleEnd() } //add-on...
  }

  func cancelImageOperations()
  {
   hostedItem?.cancelImageOperations()
   self.photoItems.forEach{ $0.cancelImageOperations() }
  }


  weak var photoFolder: PhotoFolderItem!

  let hostedViewSelectedAlpha: CGFloat = 0.5
 
  private var _selected = false
 
  var isPhotoItemSelected: Bool
  {
   set
   {
    _selected = newValue
    photoCollectionView.alpha = newValue ? hostedViewSelectedAlpha : 1
    touchSpring
    {
     self.photoCollectionView.visibleCells.compactMap{$0 as? PhotoFolderCollectionViewCell}.forEach{$0.touchSpring()}
    }
   }
   
   get {return _selected}
  }

  var photoItemView: UIView    {return self.contentView}
  var cellFrame: CGRect        {return frame}


  var photoItems: [PhotoItem]!

  var nphoto: Int = 3

  var frameSize: CGFloat = 0
 
  override func awakeFromNib()
  {

    super.awakeFromNib()
   
    hostedItem = nil
    _selected = false
    photoItems = nil
    photoCollectionView.alpha = 1
    contentView.alpha = 1
   
    let dropper = UIDropInteraction(delegate: dropDelegate)
    dropView.addInteraction(dropper)
   
    photoCollectionView.dragInteractionEnabled = true
    photoCollectionView.dragDelegate = self
   
    clearFlagMarker()
    imageRoundClip(cornerRadius: 10)
    photoCollectionView.dataSource = self
    photoCollectionView.delegate = self
   
  }

  override func prepareForReuse()
  {
   
     super.prepareForReuse()
   
     //self.hostedItem = nil
     _selected = false
     photoItems = nil
     photoCollectionView.alpha = 1
     contentView.alpha = 1
   
     groupTaskCount = 0
     clearFlagMarker()
     imageRoundClip(cornerRadius: 10)
   

  }
 
  func refresh(with image: UIImage? = nil)
  {
   refreshFlagMarker()
   refreshSpring()
  }
 
} //class PhotoFolderCell: UICollectionViewCell, PhotoSnippetCellProtocol...





