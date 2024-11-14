use image::RgbaImage;

pub fn decode_heif(bin:&[u8])->Result<RgbaImage,String>{

	let (width,height,rgb_pix)=unsafe{
		//作業コンテキストの割当
		let ctx = libheif_rs_static::heif_context_alloc();
		//引数からコンテキストに読み込み(オプション無し)
		libheif_rs_static::heif_context_read_from_memory_without_copy(ctx,bin.as_ptr() as *const _,bin.len(), std::ptr::null());
		//プライマリ画像を指すハンドルを取得
		let mut handle=std::ptr::null_mut::<libheif_rs_static::heif_image_handle>();
		libheif_rs_static::heif_context_get_primary_image_handle(ctx, &mut handle as *mut _);
		//32bitRGBAにデコードする
		let mut img=std::ptr::null_mut::<libheif_rs_static::heif_image>();
		let error=libheif_rs_static::heif_decode_image(handle, &mut img as *mut _,libheif_rs_static::heif_colorspace_heif_colorspace_RGB,libheif_rs_static::heif_chroma_heif_chroma_interleaved_RGBA,std::ptr::null());
		//何かのエラー
		if error.code>0{
			libheif_rs_static::heif_image_release(img);
			libheif_rs_static::heif_image_handle_release(handle);
			libheif_rs_static::heif_context_free(ctx);
			if error.message != std::ptr::null(){
				return Err(std::ffi::CStr::from_ptr(error.message).to_string_lossy().to_string());
			}else{
				return Err(format!("Error Code {} {}",error.code,error.subcode));
			}
		}
		//画像サイズの取得
		let width  = libheif_rs_static::heif_image_handle_get_width(handle);
		let height = libheif_rs_static::heif_image_handle_get_height(handle);
		if width<=0||height<=0{
			libheif_rs_static::heif_image_release(img);
			libheif_rs_static::heif_image_handle_release(handle);
			libheif_rs_static::heif_context_free(ctx);
			return Err(format!("Unknown Image Size {}x{}",width,height));
		}
		let mut stride=0 as std::os::raw::c_int;
		let data = libheif_rs_static::heif_image_get_plane_readonly(img,libheif_rs_static::heif_channel_heif_channel_interleaved, &mut stride as *mut _);

		if stride<=0{
			libheif_rs_static::heif_image_release(img);
			libheif_rs_static::heif_image_handle_release(handle);
			libheif_rs_static::heif_context_free(ctx);
			return Err(format!("Unknown stride {}",stride));
		}
		let width=width as usize;
		let height=height as usize;
		let stride=stride as usize;
		let data=std::slice::from_raw_parts(data,height*stride*4);
		let mut pix=vec![0u8;width*height*4];
		for y in 0..height{
			for x in 0..width{
				let ind1 = (x + y * width) * 4;
				let ind2 = x * 4 + y * stride;
				pix[ind1] = data[ind2];//R
				pix[ind1+1] = data[ind2+1];//G
				pix[ind1+2] = data[ind2+2];//B
				pix[ind1+3] = data[ind2+3];//A
			}
		}
		// clean up resources
		libheif_rs_static::heif_image_release(img);
		libheif_rs_static::heif_image_handle_release(handle);
		libheif_rs_static::heif_context_free(ctx);
		(width,height,pix)
	};
	image::RgbaImage::from_raw(width as u32,height as u32,rgb_pix).ok_or_else(||"RgbImage::from_raw None".to_owned())
}
