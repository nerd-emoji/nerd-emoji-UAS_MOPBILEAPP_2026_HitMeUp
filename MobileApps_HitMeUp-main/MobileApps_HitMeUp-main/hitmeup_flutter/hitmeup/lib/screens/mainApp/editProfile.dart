import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
	const EditProfileScreen({
		super.key,
		required this.initialName,
		required this.initialBirthday,
		required this.initialGender,
		required this.initialLocation,
		required this.initialInterests,
	});

	final String initialName;
	final String initialBirthday;
	final String initialGender;
	final String initialLocation;
	final List<String> initialInterests;

	@override
	State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
	late TextEditingController _nameController;
	late TextEditingController _birthdayController;
	late TextEditingController _genderController;
	late TextEditingController _locationController;
	late List<TextEditingController> _interestControllers;

	@override
	void initState() {
		super.initState();
		_nameController = TextEditingController(text: widget.initialName);
		_birthdayController = TextEditingController(text: widget.initialBirthday);
		_genderController = TextEditingController(text: widget.initialGender);
		_locationController = TextEditingController(text: widget.initialLocation);
		_interestControllers = widget.initialInterests
			.map((interest) => TextEditingController(text: interest))
			.toList();
	}

	@override
	void dispose() {
		_nameController.dispose();
		_birthdayController.dispose();
		_genderController.dispose();
		_locationController.dispose();
		for (var controller in _interestControllers) {
			controller.dispose();
		}
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: const BoxDecoration(gradient: AppGradient.background),
			child: Scaffold(
				backgroundColor: Colors.transparent,
				appBar: AppBar(
					automaticallyImplyLeading: true,
					backgroundColor: Colors.white,
					surfaceTintColor: Colors.white,
					elevation: 0,
					title: const Text(
						'Edit Profile',
						style: TextStyle(
							fontSize: 18,
							fontWeight: FontWeight.w600,
							color: Colors.black,
						),
					),
				),
				body: SafeArea(
					top: false,
					child: SingleChildScrollView(
						padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
						child: Column(
							children: [
								Container(
									width: double.infinity,
									padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
									decoration: BoxDecoration(
										color: Colors.white,
										borderRadius: BorderRadius.circular(20),
									),
									child: Column(
										children: [
											Container(
												width: 180,
												height: 180,
												padding: const EdgeInsets.all(5),
												decoration: const BoxDecoration(
													shape: BoxShape.circle,
													color: Color(0xFF2E8DFF),
												),
												child: const CircleAvatar(
													backgroundImage: AssetImage('assets/profilepic.png'),
												),
											),
											const SizedBox(height: 8),
											GestureDetector(
												onTap: () {
													// TODO: Implement image picker
												},
												child: const Text(
													'Change Profile Picture',
													style: TextStyle(
														color: Color(0xFF448AFF),
														fontSize: 12,
														fontWeight: FontWeight.w600,
													),
												),
											),
											const SizedBox(height: 20),

											// Name Field
											Container(
												padding: const EdgeInsets.symmetric(horizontal: 10),
												decoration: BoxDecoration(
													color: Colors.white,
													borderRadius: BorderRadius.circular(14),
													border: Border.all(
														color: const Color(0xFFF83D8D),
														width: 2,
													),
												),
												child: TextField(
													controller: _nameController,
													decoration: const InputDecoration(
														hintText: 'Full Name',
														isDense: true,
														border: InputBorder.none,
														contentPadding: EdgeInsets.symmetric(vertical: 5),
													),
													textAlign: TextAlign.center,
													style: const TextStyle(
														fontSize: 17,
														fontWeight: FontWeight.w600,
														color: Color(0xFF1F1F1F),
													),
												),
											),
											const SizedBox(height: 16),

											// Birthday Field
											_buildInputField(
												controller: _birthdayController,
												label: 'Birthday date',
											),
											const SizedBox(height: 10),

											// Gender Field
											_buildInputField(
												controller: _genderController,
												label: 'Gender',
											),
											const SizedBox(height: 10),

											// Location Field
											_buildInputField(
												controller: _locationController,
												label: 'Location',
											),
											const SizedBox(height: 10),

											// Interests Section

											const SizedBox(height: 8),
										Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												const SizedBox(
													width: 100,
													child: Padding(
														padding: EdgeInsets.only(top: 2),
														child: Text(
															'My interests',
															style: TextStyle(
																fontSize: 11,
																fontWeight: FontWeight.w600,
																color: Color(0xFF202020),
															),
														),
													),
												),
												Expanded(
													child: Column(
														children: _interestControllers.asMap().entries.map((entry) {
															int index = entry.key;
															TextEditingController controller = entry.value;
															return Column(
																children: [
																	Container(
																							padding: const EdgeInsets.symmetric(horizontal: 8),
																		decoration: BoxDecoration(
																			color: Colors.white,
																			borderRadius: BorderRadius.circular(8),
																			border: Border.all(
																				color: const Color(0xFF448AFF),
																				width: 1.5,
																			),
																		),
																		child: TextField(
																			controller: controller,
																			decoration: const InputDecoration(
																									isDense: true,
																				border: InputBorder.none,
																									contentPadding: EdgeInsets.symmetric(vertical: 5),
																			),
																			style: const TextStyle(
																				fontSize: 11,
																				color: Colors.black,
																			),
																		),
																	),
																	if (index < _interestControllers.length - 1)
																		const SizedBox(height: 8),
																],
															);
														}).toList(),
													),
												),
											],
										),
										const SizedBox(height: 24),

											// Done Button
											SizedBox(
												width: 200,
												height: 40,
												child: ElevatedButton(
													onPressed: _savProfile,
													style: ElevatedButton.styleFrom(
														backgroundColor: const Color(0xFFF83D8D),
														foregroundColor: Colors.white,
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(20),
														),
														elevation: 0,
													),
													child: const Text(
														'Done',
														style: TextStyle(
															fontSize: 18,
															fontWeight: FontWeight.w600,
														),
													),
												),
											),
										],
									),
								),
							],
						),
					),
				)
			),
		);
	}

	Widget _buildInputField({
		required TextEditingController controller,
		required String label,
	}) {
		return Row(
			children: [
				SizedBox(
					width: 100,
					child: Text(
						label,
						style: const TextStyle(
							fontSize: 11,
							fontWeight: FontWeight.w600,
							color: Color(0xFF202020),
						),
					),
				),
				Expanded(
					child: Container(
						padding: const EdgeInsets.symmetric(horizontal: 8),
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(6),
							border: Border.all(
								color: const Color(0xFF448AFF),
								width: 1.5,
							),
						),
						child: TextField(
							controller: controller,
							decoration: const InputDecoration(
												isDense: true,
								border: InputBorder.none,
												contentPadding: EdgeInsets.symmetric(vertical: 5),
							),
							style: const TextStyle(
								fontSize: 11,
								color: Colors.black,
							),
						),
					),
				),
			],
		);
	}

	void _savProfile() {
		// Collect all the edited data
		final updatedData = {
			'name': _nameController.text,
			'birthday': _birthdayController.text,
			'gender': _genderController.text,
			'location': _locationController.text,
			'interests': _interestControllers.map((c) => c.text).toList(),
		};

		// Return the updated data
		Navigator.of(context).pop(updatedData);
	}
}
