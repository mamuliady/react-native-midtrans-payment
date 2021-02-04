
# react-native-midtrans-payment

## Getting started

`$ yarn add @yustinWill/react-native-midtrans-payment`

### Mostly automatic installation

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `@yustinWill/react-native-midtrans-payment` and add `ReactNativeMidtrans.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libReactNativeMidtrans.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.paymentgateway.MidtransPackage;` to the imports at the top of the file
  - Add `new MidtransPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-midtrans-payment'
  	project(':react-native-midtrans-payment').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-midtrans-payment/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-midtrans-payment')
  	```
4. Append midtrans repository to application level build.gradle
    ```
        maven { url "http://dl.bintray.com/pt-midtrans/maven" }
        maven { url "https://jitpack.io" }
    ```
5. Change t

## Usage
```javascript
import PaymentGateway from '@yustinWill/react-native-midtrans-payment';

async pay(){
        const optionConect = {
            clientKey: "your client key",
            urlMerchant: "https://domain.net/",
            sandbox: false // this affect iOS
        }

        const transRequest = {
            transactionId: "0001",
            totalAmount: 4000
        }

        const itemDetails = [
            {id: "001", price: 1000, qty: 4, name: "peanuts"}
        ];

        const creditCardOptions = {
            saveCard: false,
            saveToken: false,
            paymentMode: "Normal",
            secure: false
        };

        const userDetail = {
            fullName: "jhon",
            email: "jhon@payment.com",
            phoneNumber: "0850000000",
            userId: "U01",
            address: "street coffee",
            city: "yogyakarta",
            country: "IDN", <-- must be standard 3 digit country code
            zipCode: "59382"
        };

        const optionColorTheme = {
            primary: '#c51f1f',
            primaryDark: '#1a4794',
            secondary: '#1fce38'
        }

        const optionFont = {
            defaultText: "open_sans_regular.ttf",
            semiBoldText: "open_sans_semibold.ttf",
            boldText: "open_sans_bold.ttf"
        }

        const callback = (res) => {
			console.log(res)
			switch (res) {
				case 'success':
				case 'challenge':
				case 'pending':
					// Completed
					break;
				case 'cancelled':
					// Cancelled
					break;
				default:
					// Failed
					break;
			}
		};

        PaymentGateway.checkOut(
            optionConect,
            transRequest,
            itemDetails,
            creditCardOptions,
            userDetail,
            optionColorTheme,
            optionFont,
            callback
        );
    }
```
  
