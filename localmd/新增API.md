# 新增API

## 1.统一回调接口

```java
/**
 *
 * @param <T> 数据泛型类型
 */
public interface P2PCallback<T> {
    //错误码
    int ERR_TIME_OUT=-3;//超时
    /**
     *
     * @param data 实际返回数据
     */
    void onSuccess(T data);

    /**
     *
     * @param errCode 错误码
     * @param message 错误提示
     */
    void onFailure(int errCode,String message);
}


```

## 2.新增方法

1. 通知固件升级

   ```java
       /**
        * 
        * @param url 固件下载路径
        * @param callback 方法回调，onsuccess方法data可以为null
        */
       public void notifyUpgradeUrl(String url, P2PCallback<String> callback)
   ```



2. 查询sd卡回放倍数

   ```java
   /**
        * 查询sd卡当前回放的倍数，data为倍数，eg. data=1.5代表1.5倍速
        * @param callback
        */
       public void getPlaybackSpeed(P2PCallback<Integer> callback)
   ```

3. 设置sd卡回放倍数

   ```java
   /**
        * 设置当前连接用户回放的倍数
        * @param speed 倍数
        * @param callback data 返回设置成功的倍数
        */
       public void setPlaybackSpeed(Integer speed,P2PCallback<Integer> callback)
   ```

4. 暂停正在播放的sd卡回放

   ```java
   /**
        * 暂停当前播放的sd卡录像
        */
       public void pausePlayback(P2PCallback<String> callback)
   ```

5. 恢复暂停的sd卡回放

   ```java
    /**
        * 恢复播放sd卡视频
        * @param callback
        */
       public void resumePlayback(P2PCallback<String> callback)
   ```

6. 设置摄像头申请云存储预签名put请求的后台服务接口地址

   ```java
       /**
        * 设置摄像头申请云存储预签名put请求的后台服务接口地址
        * @param url 接口全路径
        * @param callback data为设置的地址
        */
       public void setCloudStorageGateway(String url,P2PCallback<String> callback){
   
       }
   ```

7. 查询摄像头申请云存储预签名put请求的后台服务接口地址

   ```
   
       /**
        * 查询摄像头申请云存储预签名put请求的后台服务接口地址
        * @param callback data为url地址
        */
       public void getCloudStorageGateway(P2PCallback<String> callback){}
   ```

8. 设置摄像头上传云存储对象成功后，上报服务器接口地址

   ```java
                  mCamera.setCloudStorageUploadGateway("http://116.63.91.111/addFileInfo", new com.khj.P2PCallback<String>() {
                       @Override
                       public void onSuccess(String s) {
                           KLog.i("setCloudStorageUploadGateway:onSuccess:"+s);
                       }
   
                       @Override
                       public void onFailure(int i, String s) {
                           KLog.i("setCloudStorageUploadGateway:onFailure:"+s);
                       }
                   });
   ```

9. 查询摄像头上报云存储对象接口地址

   ```java
                   mCamera.getCloudStorageUploadGateway(new com.khj.P2PCallback<String>() {
                       @Override
                       public void onSuccess(String s) {
                           KLog.i("getCloudStorageUploadGateway:"+s);
                       }
   
                       @Override
                       public void onFailure(int i, String s) {
   
                       }
                   });
   
   ```

   