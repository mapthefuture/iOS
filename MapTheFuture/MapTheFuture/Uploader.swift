
import Alamofire
import Foundation
import UIKit





private struct FileUploadInfo {
    var name:String
    var mimeType:String
    var fileName:String
    var url:NSURL?
    var data:NSData?
    
    init( name: String, withFileURL url: NSURL, withMimeType mimeType: String? = nil ) {
        self.name = name
        self.url = url
        self.fileName = name
        self.mimeType = "application/octet-stream"
        if mimeType != nil {
            self.mimeType = mimeType!
        }
        if let _name = url.lastPathComponent {
            fileName = _name
        }
        if mimeType == nil, let _extension = url.pathExtension {
            switch _extension.lowercaseString {
                
            case "jpeg", "jpg":
                self.mimeType = "image/jpeg"
                
            case "png":
                self.mimeType = "image/png"
                
            default:
                self.mimeType = "application/octet-stream"
            }
        }
    }
    
    init( name: String, withData data: NSData, withMimeType mimeType: String ) {
        self.name = name
        self.data = data
        self.fileName = name
        self.mimeType = mimeType
    }
}

class FileUploader {
    
    private var parameters = [String:String]()
    private var files = [FileUploadInfo]()
    private var headers = [String:String]()
    
    func setValue( value: String, forParameter parameter: String ) {
        parameters[parameter] = value
    }
    
    func setValue( value: String, forHeader header: String ) {
        headers[header] = value
    }
    
    func addParametersFrom( map: [String:String] ) {
        for (key,value) in map {
            parameters[key] = value
        }
    }
    
    func addHeadersFrom( map: [String:String] ) {
        for (key,value) in map {
            headers[key] = value
        }
    }
    
    func addFileURL( url: NSURL, withName name: String, withMimeType mimeType:String? = nil ) {
        files.append( FileUploadInfo( name: name, withFileURL: url, withMimeType: mimeType ) )
    }
    
    func addFileData( data: NSData, withName name: String, withMimeType mimeType:String = "application/octet-stream" ) {
        files.append( FileUploadInfo( name: name, withData: data, withMimeType: mimeType ) )
    }
    
    func uploadFile( request sourceRequest: NSURLRequest ) -> Request? {
        let request = sourceRequest.mutableCopy() as! NSMutableURLRequest
        let boundary = "FileUploader-boundary-\(arc4random())-\(arc4random())"
        request.setValue( "multipart/form-data;boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let data = NSMutableData()
        
        for (name, value) in headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
        
        // Amazon S3 (probably others) wont take parameters after files, so we put them first
        for (key, value) in parameters {
            data.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            data.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        for fileUploadInfo in files {
            data.appendData( "\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)! )
            data.appendData( "Content-Disposition: form-data; name=\"\(fileUploadInfo.name)\"; filename=\"\(fileUploadInfo.fileName)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            data.appendData( "Content-Type: \(fileUploadInfo.mimeType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            if fileUploadInfo.data != nil {
                data.appendData( fileUploadInfo.data! )
            }
            else if fileUploadInfo.url != nil, let fileData = NSData(contentsOfURL: fileUploadInfo.url!) {
                data.appendData( fileData )
            }
            else { // ToDo: report error
                return nil
            }
        }
        
        data.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        return Alamofire.upload( request, data: data )
    }
    
}