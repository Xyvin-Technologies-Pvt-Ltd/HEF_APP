import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';

class UserNotifier extends StateNotifier<AsyncValue<UserModel>> {
  final StateNotifierProviderRef<UserNotifier, AsyncValue<UserModel>> ref;

  UserNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initializeUser();
  }

  /// Initializes the user when the notifier is first created
  Future<void> _initializeUser() async {
    if (mounted) {
      await _fetchUserDetails();
    }
  }

  /// Refresh user details by re-fetching them and updating the state
  Future<void> refreshUser() async {
    if (mounted) {
      state = const AsyncValue.loading(); // Set state to loading during refresh
      await _fetchUserDetails();
    }
  }

  /// Helper function to fetch user details and update the state
  Future<void> _fetchUserDetails() async {
    try {
      log('Fetching user details');
      final user = await ref.read(fetchUserDetailsProvider(id).future);
      state = AsyncValue.data(user ?? UserModel());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      log('Error fetching user details: $e');
      log(stackTrace.toString());
    }
  }

  void updateName({
    String? name,
  }) {
    state = state.whenData((user) => user.copyWith(name: name));
  }

  void updateCompany(Company updatedCompany, int index) {
    state = state.whenData((user) {
      final updatedCompanyList = [...?user.company];

      // Check if any field has a valid non-empty value
      bool hasValidData = [
            updatedCompany.name,
            updatedCompany.designation,
            updatedCompany.email,
            updatedCompany.phone
          ].any((field) => field?.trim().isNotEmpty ?? false) ||
          (updatedCompany.websites?.isNotEmpty ?? false);

      if (!hasValidData) {
        // Remove company if all fields are empty
        if (index >= 0 && index < updatedCompanyList.length) {
          updatedCompanyList.removeAt(index);
        }
      } else {
        if (index >= 0 && index < updatedCompanyList.length) {
          log(updatedCompany.name ?? '');
          updatedCompanyList[index] = updatedCompanyList[index].copyWith(
            designation: updatedCompany.designation ??
                updatedCompanyList[index].designation,
            email: updatedCompany.email ?? updatedCompanyList[index].email,
            name: updatedCompany.name ?? updatedCompanyList[index].name,
            phone: updatedCompany.phone ?? updatedCompanyList[index].phone,
            websites:
                updatedCompany.websites ?? updatedCompanyList[index].websites,
          );
        } else if (index == updatedCompanyList.length) {
          // Add a new company
          updatedCompanyList.add(updatedCompany);
        }
      }

      return user.copyWith(company: updatedCompanyList);
    });
  }

  void updateSecondaryPhone(SecondaryPhone? secondaryPhone) {
    state =
        state.whenData((user) => user.copyWith(secondaryPhone: secondaryPhone));
  }

  void updateEmail(String? email) {
    state = state.whenData((user) => user.copyWith(email: email));
  }

  void updateBio(String? bio) {
    state = state.whenData((user) => user.copyWith(bio: bio));
  }

  void updateAddress(String? address) {
    state = state.whenData((user) => user.copyWith(address: address));
  }

  void updateProfilePicture(String? profilePicture) {
    state = state.whenData((user) => user.copyWith(image: profilePicture));
  }

  void updateAwards(List<Award> awards) {
    state = state.whenData((user) => user.copyWith(awards: awards));
  }

  void updateCertificate(List<Link> certificates) {
    state = state.whenData((user) => user.copyWith(certificates: certificates));
  }

  // void updateSocialMedia(List<Link> social) {
  //   state = state.whenData((user) => user.copyWith(social: social));
  // }
  // void updateCompanyLogo(String? companyLogo) {
  //   state = state.whenData((user) => user.copyWith(company: Company(logo: companyLogo)));
  // }
  //   void updateCompanyDesignation(String? designation) {
  //   state = state.whenData((user) => user.copyWith(company: Company(designation: designation)));
  // }
  //   void updateCompanyLogo(String? companyLogo) {
  //   state = state.whenData((user) => user.copyWith(company: Company(logo: companyLogo)));
  // }
  //   void updateCompanyLogo(String? companyLogo) {
  //   state = state.whenData((user) => user.copyWith(company: Company(logo: companyLogo)));
  // }

  void updateSocialMedia(
      List<Link> socialmedias, String platform, String newUrl) {
    log(newUrl);
    if (platform.isNotEmpty) {
      final index = socialmedias.indexWhere((item) => item.name == platform);
      log('platform:$platform');
      if (index != -1) {
        if (newUrl.isNotEmpty) {
          // Update the existing social media link
          final updatedSocialMedia = socialmedias[index].copyWith(link: newUrl);
          socialmedias[index] = updatedSocialMedia;
        } else {
          // Remove the social media link if newUrl is empty
          socialmedias.removeAt(index);
        }
      } else if (newUrl.isNotEmpty) {
        // Add new social media link if platform doesn't exist and newUrl is not empty
        final newSocialMedia = Link(name: platform, link: newUrl);
        socialmedias.add(newSocialMedia);
      }

      // Update the state with the modified socialmedias list
      state = state.whenData((user) => user.copyWith(social: socialmedias));
    } else {
      // If platform is empty, clear the social media list
      state = state.whenData((user) => user.copyWith(social: []));
    }

    log('Updated Social Media $socialmedias');
  }

  void updateVideos(List<Link> videos) {
    state = state.whenData((user) => user.copyWith(videos: videos));
  }

  void removeVideo(Link videoToRemove) {
    state = state.whenData((user) {
      final updatedVideo =
          user.videos!.where((video) => video != videoToRemove).toList();
      return user.copyWith(videos: updatedVideo);
    });
  }

  void updateWebsite(List<Link> websites) {
    state = state.whenData((user) => user.copyWith(websites: websites));
    log('website count in updation ${websites.length}');
  }

  void removeWebsite(Link websiteToRemove) {
    state = state.whenData((user) {
      final updatedWebsites = user.websites!
          .where((website) => website != websiteToRemove)
          .toList();
      return user.copyWith(websites: updatedWebsites);
    });
  }

  void updatePhone(String phone) {
    state = state.whenData(
      (user) => user.copyWith(phone: phone),
    );
  }

  void removeAward(Award awardToRemove) {
    state = state.whenData((user) {
      final updatedAwards =
          user.awards!.where((award) => award != awardToRemove).toList();
      return user.copyWith(awards: updatedAwards);
    });
  }

  void removeCertificate(Link certificateToRemove) {
    state = state.whenData((user) {
      final updatedCertificate = user.certificates!
          .where((certificate) => certificate != certificateToRemove)
          .toList();
      return user.copyWith(certificates: updatedCertificate);
    });
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<UserModel>>((ref) {
  return UserNotifier(ref);
});
